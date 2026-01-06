import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../services/github_service.dart';
import '../services/storage_service.dart';
import '../widgets/pet_widget.dart';
import '../providers/pet_provider.dart';
import '../utils/game_constants.dart';
import '../services/stat_calculator.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserSettings? _settings;
  final GitHubService _githubService = GitHubService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String _statusMessage = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load saved settings
      _settings = await _storageService.loadSettings();

      // Configure GitHub service if configured
      if (_settings!.isConfigured) {
        _githubService.setCredentials(
          _settings!.githubUsername!,
          _settings!.githubToken,
        );
      }

      // Initialize pet provider
      if (mounted) {
        final username = _settings!.isConfigured 
            ? _settings!.githubUsername! 
            : 'guest';
        await context.read<PetProvider>().initialize(username);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isInitialized = true;
          _statusMessage = 'Error initializing app. Please configure settings.';
        });
      }
    }
  }

  Future<void> _fetchAndFeedFromGitHub() async {
    if (_settings == null || !_settings!.isConfigured) {
      _showSettingsDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching commits from GitHub...';
    });

    try {
      final stats = await _githubService.fetchRecentCommits(days: 7);
      
      final newCommits = stats.recentCommits
          .where((commit) => !_settings!.usedCommitShas.contains(commit.sha))
          .toList();
      
      final newCommitCount = newCommits.length;

      if (newCommitCount > 0) {
        // Feed pet through provider
        if (mounted) {
          await context.read<PetProvider>().onCommit(
            newCommitCount,
            commitDate: newCommits.first.date,
          );
        }
        
        // Mark commits as used
        for (var commit in newCommits) {
          _settings!.usedCommitShas.add(commit.sha);
        }
        
        await _storageService.saveSettings(_settings!);
        
        setState(() {
          _statusMessage = '🎉 Fed with $newCommitCount new commit${newCommitCount > 1 ? 's' : ''}!';
          
          if (newCommits.isNotEmpty) {
            final latestCommit = newCommits.first;
            final commitMsg = latestCommit.message.length > 50 
                ? '${latestCommit.message.substring(0, 50)}...'
                : latestCommit.message;
            _statusMessage += '\n\nLatest: "$commitMsg"';
          }
        });
      } else {
        final totalFound = stats.recentCommits.length;
        setState(() {
          if (totalFound > 0) {
            _statusMessage = '😐 Found $totalFound commit${totalFound > 1 ? 's' : ''}, but already used!';
          } else {
            _statusMessage = '😢 No commits found in the last 7 days. Push some code!';
          }
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playWithPet() async {
    final petProvider = context.read<PetProvider>();
    if (petProvider.state != null && petProvider.state!.energy < 15) {
      setState(() {
        _statusMessage = '😴 Too tired to play! Let your pet rest first.';
      });
      return;
    }

    if (mounted) {
      await context.read<PetProvider>().play();
      setState(() {
        _statusMessage = '🎮 Played with your pet! Happiness increased!';
      });
    }
  }

  Future<void> _letPetRest() async {
    if (mounted) {
      await context.read<PetProvider>().rest();
      setState(() {
        _statusMessage = '😴 Your pet is resting... Energy restored!';
      });
    }
  }

  void _showSettingsDialog() {
    final usernameController = TextEditingController(
      text: _settings?.githubUsername,
    );
    final tokenController = TextEditingController(
      text: _settings?.githubToken,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configure your GitHub account to start feeding your pet with commits!',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'GitHub Username',
                  hintText: 'octocat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'Personal Access Token (optional)',
                  hintText: 'ghp_...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  helperText: 'Increases API rate limits',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Create token at: github.com/settings/tokens\nNo special permissions needed.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              final token = tokenController.text.trim();

              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Username is required')),
                );
                return;
              }

              _settings ??= UserSettings();
              _settings!.githubUsername = username;
              _settings!.githubToken = token.isEmpty ? null : token;
              
              _githubService.setCredentials(username, token.isEmpty ? null : token);
              await _storageService.saveSettings(_settings!);

              // Re-initialize pet with new username
              if (mounted) {
                await context.read<PetProvider>().initialize(username);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Settings saved!')),
                );
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Used Commits'),
        content: const Text(
          'This will allow you to redeem commits again. Use this for testing or if you want to start fresh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _settings?.usedCommitShas.clear();
              });
              if (_settings != null) {
                await _storageService.saveSettings(_settings!);
              }
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Used commits reset!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _navigateToStatistics() {
    final statistics = context.read<PetProvider>().statistics;
    if (statistics != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatisticsScreen(statistics: statistics),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading TamaGit...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<PetProvider>(
          builder: (context, petProvider, child) {
            final state = petProvider.state;
            return Text(
              'TamaGit${state != null ? ' - ${state.growthStage.name.toUpperCase()}' : ''}',
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStatistics,
            tooltip: 'Statistics',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                _showSettingsDialog();
              } else if (value == 'reset') {
                _showResetDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reset Commits'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pet Display
            const PetWidget(),

            const SizedBox(height: 24),

            // Pet Stats Card
            Consumer<PetProvider>(
              builder: (context, petProvider, child) {
                final state = petProvider.state;
                if (state == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Configure GitHub to get started'),
                    ),
                  );
                }

                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Mood indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              StatCalculator.getMoodIcon(state.mood),
                              size: 32,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                StatCalculator.getStatusMessage(state.mood),
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24),
                        
                        // Stats bars
                        _buildStatBar(
                          'Health',
                          state.health,
                          Icons.favorite,
                          StatCalculator.getStatColor(state.health),
                        ),
                        const SizedBox(height: 8),
                        _buildStatBar(
                          'Happiness',
                          state.happiness,
                          Icons.sentiment_satisfied,
                          StatCalculator.getStatColor(state.happiness),
                        ),
                        const SizedBox(height: 8),
                        _buildStatBar(
                          'Energy',
                          state.energy,
                          Icons.battery_charging_full,
                          StatCalculator.getStatColor(state.energy),
                        ),
                        
                        const Divider(height: 24),
                        
                        // Growth info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoChip(
                              'Commits',
                              state.totalCommits.toString(),
                              Icons.commit,
                            ),
                            _buildInfoChip(
                              'Age',
                              '${state.age} days',
                              Icons.cake,
                            ),
                            _buildInfoChip(
                              'Streak',
                              '${state.commitStreak} 🔥',
                              Icons.local_fire_department,
                              highlight: state.commitStreak > 7,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons (Play and Rest only)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _playWithPet,
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _letPetRest,
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Rest'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // GitHub Feed Button (Main feeding mechanic)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchAndFeedFromGitHub,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_download),
                label: Text(
                  _settings?.isConfigured == true 
                      ? 'Feed from GitHub Commits' 
                      : 'Configure GitHub',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Helper text
            if (_settings?.isConfigured != true)
              const Text(
                'Tap the button above to set up your GitHub account\nand start feeding your pet with commits!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              '$value / ${GameConstants.maxStat}',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / GameConstants.maxStat,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.orange : null,
            ),
          ),
        ],
      ),
      backgroundColor: highlight ? Colors.orange[50] : null,
    );
  }
}