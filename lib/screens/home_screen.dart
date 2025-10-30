import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/user_settings.dart';
import '../services/github_service.dart';
import '../services/storage_service.dart';
import '../widgets/pet_widget.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Pet _pet;
  late UserSettings _settings;
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
    setState(() {
      _isLoading = true;
    });

    // Load saved data
    _settings = await _storageService.loadSettings();
    Pet? savedPet = await _storageService.loadPet();

    if (savedPet != null) {
      _pet = savedPet;
      _pet.decay(); // Apply decay since last session
    } else {
      _pet = Pet();
    }

    // Configure GitHub service
    if (_settings.isConfigured) {
      _githubService.setCredentials(_settings.githubUsername!, _settings.githubToken);
    }

    setState(() {
      _isLoading = false;
      _isInitialized = true;
    });

    // Auto-save pet state
    await _storageService.savePet(_pet);
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
      final stats = await _githubService.fetchRecentCommits();
      
      setState(() {
        if (stats.commitCount > 0) {
          _pet.feed(stats.commitCount);
          _statusMessage = '🎉 Fed with ${stats.commitCount} commit${stats.commitCount > 1 ? 's' : ''}!';
        } else {
          _statusMessage = '😢 No commits found today. Push some code!';
        }
      });

      // Save updated pet state
      await _storageService.savePet(_pet);
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

              if (mounted) {
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

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$value%'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: AppConstants.statBarHeight,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.appName} - ${_pet.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Pet Display
            PetWidget(
              pet: _pet,
              onTap: () {
                setState(() {
                  _pet.happiness = (_pet.happiness + 5).clamp(0, 100);
                  _storageService.savePet(_pet);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🥰 Pet petted!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Pet Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Stage: ${_pet.stage.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Commits: ${_pet.totalCommits}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatBar('Hunger', _pet.hunger, AppConstants.happyColor),
                    const SizedBox(height: 12),
                    _buildStatBar('Happiness', _pet.happiness, Colors.amber),
                    const SizedBox(height: 12),
                    _buildStatBar('Energy', _pet.energy, Colors.blue),
                  ],
                ),
              ),
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