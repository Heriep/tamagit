class Statistics {
  int totalCommits;
  int currentStreak;
  int longestStreak;
  int totalPetInteractions;
  Map<String, int> commitsByDay;
  DateTime firstCommitDate;
  DateTime? lastCommitDate;

  Statistics({
    required this.totalCommits,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPetInteractions,
    required this.commitsByDay,
    required this.firstCommitDate,
    this.lastCommitDate,
  });

  factory Statistics.initial() {
    return Statistics(
      totalCommits: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPetInteractions: 0,
      commitsByDay: {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      },
      firstCommitDate: DateTime.now(),
    );
  }

  void incrementCommits() {
    totalCommits++;
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    commitsByDay[dayName] = (commitsByDay[dayName] ?? 0) + 1;
    
    _updateStreak(now);
  }

  void incrementInteractions() {
    totalPetInteractions++;
  }

  void _updateStreak(DateTime now) {
    if (lastCommitDate == null) {
      currentStreak = 1;
      longestStreak = 1;
    } else {
      final difference = now.difference(lastCommitDate!).inDays;
      if (difference == 0) {
        // Same day, keep streak
      } else if (difference == 1) {
        // Consecutive day
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        // Streak broken
        currentStreak = 1;
      }
    }
    lastCommitDate = now;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}