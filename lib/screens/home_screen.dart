import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../services/github_service.dart';
import '../services/storage_service.dart';
import '../services/statistics_service.dart';
import '../widgets/pet_widget.dart';
import '../providers/pet_provider.dart';
import '../utils/constants.dart';
import 'statistics_screen.dart';
import '../models/statistics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserSettings _settings;
  final GitHubService _githubService = GitHubService();
  final StorageService _storageService = StorageService();
  final StatisticsService _statisticsService = StatisticsService();
  late Statistics _statistics;

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

      // Load saved data
      _settings = await _storageService.loadSettings();
      _statistics = await _statisticsService.loadStatistics();

      // Configure GitHub service if configured
      if (_settings.isConfigured) {
        _githubService.setCredentials(_settings.githubUsername!, _settings.githubToken);
        
        // Initialize pet provider with username
        if (mounted) {
          await context.read<PetProvider>().initialize(_settings.githubUsername!);
        }
      } else {
        // Initialize with a default username if not configured
        if (mounted) {
          await context.read<PetProvider>().initialize('guest');
        }
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

  Future<void> _fetchAndFeed() async {
    if (!_settings.isConfigured) {
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
          .where((commit) => !_settings.usedCommitShas.contains(commit.sha))
          .toList();
      
      final newCommitCount = newCommits.length;

      if (newCommitCount > 0) {
        // Update pet through provider
        context.read<PetProvider>().onCommit(newCommitCount);
        
        // Update statistics
        for (int i = 0; i < newCommitCount; i++) {
          _statistics.incrementCommits();
        }
        
        for (var commit in newCommits) {
          _settings.usedCommitShas.add(commit.sha);
        }
        
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

      await _storageService.saveSettings(_settings);
      await _statisticsService.saveStatistics(_statistics);
      await _storageService.saveLastUpdate(DateTime.now());
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

  void _showSettingsDialog() {
    final usernameController = TextEditingController(text: _settings.githubUsername);
    final tokenController = TextEditingController(text: _settings.githubToken);

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
                'Configure your GitHub account to start feeding your pet!',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'GitHub Username',
                  hintText: 'octocat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'Personal Access Token (optional)',
                  hintText: 'ghp_...',
                  border: OutlineInputBorder(),
                  helperText: 'Increases API rate limits',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Create token at: github.com/settings/tokens',
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

              _settings.githubUsername = username;
              _settings.githubToken = token.isEmpty ? null : token;
              
              _githubService.setCredentials(username, token.isEmpty ? null : token);
              await _storageService.saveSettings(_settings);

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
                _settings.usedCommitShas.clear();
              });
              await _storageService.saveSettings(_settings);
              
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
            return Text('${AppConstants.appName}${state != null ? ' - Stage: ${state.growthStage.name}' : ''}');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsScreen(
                    statistics: _statistics,
                  ),
                ),
              );
            },
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
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Pet Display
            const PetWidget(),

            const SizedBox(height: 24),

            // Pet Info
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Stage: ${state.growthStage.name.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Commits: ${state.totalCommits}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Age: ${state.age} days',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Streak: ${state.commitStreak} days',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: state.commitStreak > 7 ? Colors.green : null,
                            fontWeight: state.commitStreak > 7 ? FontWeight.bold : null,
                          ),
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
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Feed Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchAndFeed,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restaurant),
                label: Text(
                  _settings.isConfigured ? 'Feed from GitHub' : 'Configure GitHub',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.happyColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Helper text
            if (!_settings.isConfigured)
              const Text(
                'Tap the button above to set up your GitHub account',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}