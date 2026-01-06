import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../models/aquatan.dart';
import '../utils/game_constants.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  late int _health;
  late int _happiness;
  late int _energy;
  late int _age;
  late int _totalCommits;
  late int _commitStreak;
  late AquatanMood _selectedMood;
  late AquatanGrowthStage _selectedStage;
  late AquatanPose _selectedPose;

  @override
  void initState() {
    super.initState();
    final state = context.read<PetProvider>().state;
    if (state != null) {
      _health = state.health;
      _happiness = state.happiness;
      _energy = state.energy;
      _age = state.age;
      _totalCommits = state.totalCommits;
      _commitStreak = state.commitStreak;
      _selectedMood = state.mood;
      _selectedStage = state.growthStage;
      _selectedPose = state.currentPose;
    } else {
      _health = 100;
      _happiness = 100;
      _energy = 100;
      _age = 0;
      _totalCommits = 0;
      _commitStreak = 0;
      _selectedMood = AquatanMood.happy;
      _selectedStage = AquatanGrowthStage.egg;
      _selectedPose = AquatanPose.idle;
    }
  }

  void _applyChanges() {
    final petProvider = context.read<PetProvider>();
    final currentState = petProvider.state;
    
    if (currentState != null) {
      final newStats = currentState.stats.copyWith(
        health: _health,
        happiness: _happiness,
        energy: _energy,
      );

      final newState = currentState.copyWith(
        stats: newStats,
        age: _age,
        totalCommits: _totalCommits,
        commitStreak: _commitStreak,
        mood: _selectedMood,
        growthStage: _selectedStage,
        currentPose: _selectedPose,
      );

      // Force update through the manager
      petProvider.debugUpdateState(newState);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Debug stats applied!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _health = 100;
      _happiness = 100;
      _energy = 100;
      _age = 0;
      _totalCommits = 0;
      _commitStreak = 0;
      _selectedMood = AquatanMood.happy;
      _selectedStage = AquatanGrowthStage.egg;
      _selectedPose = AquatanPose.idle;
    });
  }

  void _setPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'sick':
          _health = 15;
          _happiness = 30;
          _energy = 20;
          _selectedMood = AquatanMood.sick;
          break;
        case 'tired':
          _health = 50;
          _happiness = 50;
          _energy = 10;
          _selectedMood = AquatanMood.tired;
          break;
        case 'excited':
          _health = 100;
          _happiness = 100;
          _energy = 100;
          _selectedMood = AquatanMood.excited;
          break;
        case 'elder':
          _age = 200;
          _totalCommits = 2000;
          _commitStreak = 50;
          _selectedStage = AquatanGrowthStage.elder;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Debug Controls'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to defaults',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _applyChanges,
            tooltip: 'Apply changes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEBUG MODE: Changes will override normal game logic',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Presets
            const Text(
              'Quick Presets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _setPreset('sick'),
                  icon: const Icon(Icons.sick),
                  label: const Text('Sick'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _setPreset('tired'),
                  icon: const Icon(Icons.battery_2_bar),
                  label: const Text('Tired'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _setPreset('excited'),
                  icon: const Icon(Icons.celebration),
                  label: const Text('Excited'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
                ),
                ElevatedButton.icon(
                  onPressed: () => _setPreset('elder'),
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Elder'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[100]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats sliders
            const Text(
              'Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatSlider(
              'Health',
              _health,
              Icons.favorite,
              Colors.red,
              (value) => setState(() => _health = value.round()),
            ),
            _buildStatSlider(
              'Happiness',
              _happiness,
              Icons.sentiment_satisfied,
              Colors.amber,
              (value) => setState(() => _happiness = value.round()),
            ),
            _buildStatSlider(
              'Energy',
              _energy,
              Icons.battery_charging_full,
              Colors.green,
              (value) => setState(() => _energy = value.round()),
            ),

            const Divider(height: 32),

            // Progression sliders
            const Text(
              'Progression',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildNumberSlider(
              'Age (days)',
              _age,
              0,
              365,
              Icons.cake,
              Colors.pink,
              (value) => setState(() => _age = value.round()),
            ),
            _buildNumberSlider(
              'Total Commits',
              _totalCommits,
              0,
              5000,
              Icons.commit,
              Colors.blue,
              (value) => setState(() => _totalCommits = value.round()),
            ),
            _buildNumberSlider(
              'Commit Streak',
              _commitStreak,
              0,
              100,
              Icons.local_fire_department,
              Colors.orange,
              (value) => setState(() => _commitStreak = value.round()),
            ),

            const Divider(height: 32),

            // Mood selector
            const Text(
              'Mood',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AquatanMood>(
              value: _selectedMood,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.mood),
              ),
              items: AquatanMood.values.map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMood = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Growth stage selector
            const Text(
              'Growth Stage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AquatanGrowthStage>(
              value: _selectedStage,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.trending_up),
              ),
              items: AquatanGrowthStage.values.map((stage) {
                return DropdownMenuItem(
                  value: stage,
                  child: Text(stage.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStage = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Pose selector
            const Text(
              'Current Pose',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AquatanPose>(
              value: _selectedPose,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_run),
              ),
              items: AquatanPose.values.map((pose) {
                return DropdownMenuItem(
                  value: pose,
                  child: Text(pose.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPose = value);
                }
              },
            ),

            const SizedBox(height: 32),

            // Apply button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _applyChanges,
                icon: const Icon(Icons.check_circle),
                label: const Text('APPLY CHANGES'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSlider(
    String label,
    int value,
    IconData icon,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '$value / ${GameConstants.maxStat}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: 0,
              max: GameConstants.maxStat.toDouble(),
              divisions: GameConstants.maxStat,
              label: value.toString(),
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSlider(
    String label,
    int value,
    int min,
    int max,
    IconData icon,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  value.toString(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: value.toString(),
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}