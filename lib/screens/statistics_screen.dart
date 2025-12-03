import 'package:flutter/material.dart';
import '../models/statistics.dart';

class StatisticsScreen extends StatelessWidget {
  final Statistics statistics;

  const StatisticsScreen({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              context,
              'Total Commits',
              statistics.totalCommits.toString(),
              Icons.commit,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Current Streak',
              '${statistics.currentStreak} days',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Longest Streak',
              '${statistics.longestStreak} days',
              Icons.emoji_events,
              Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Pet Interactions',
              statistics.totalPetInteractions.toString(),
              Icons.pets,
              Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Weekly Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final dayIndex = days.indexOf(day);
                final commits = statistics.commitsByDay[day] ?? 0;
                final maxCommits = statistics.commitsByDay.values.isEmpty
                    ? 1
                    : statistics.commitsByDay.values.reduce((a, b) => a > b ? a : b);
                
                return Column(
                  children: [
                    Text(
                      day,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 32,
                          height: maxCommits > 0 ? (commits / maxCommits * 100) : 0,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commits.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}