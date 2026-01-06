class Statistics {
  int totalCommits;
  int currentStreak;
  int longestStreak;
  int totalFeeds;
  int totalPlays;
  int totalRests;
  Map<String, int> commitsByDay;
  DateTime? lastCommitDate;
  DateTime createdAt;

  Statistics({
    required this.totalCommits,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalFeeds,
    required this.totalPlays,
    required this.totalRests,
    required this.commitsByDay,
    this.lastCommitDate,
    required this.createdAt,
  });

  factory Statistics.initial() {
    return Statistics(
      totalCommits: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalFeeds: 0,
      totalPlays: 0,
      totalRests: 0,
      commitsByDay: {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      },
      createdAt: DateTime.now(),
    );
  }

  int get totalPetInteractions => totalFeeds + totalPlays + totalRests;

  void recordCommits(int count, DateTime commitDate) {
    totalCommits += count;
    
    final dayName = _getDayName(commitDate.weekday);
    commitsByDay[dayName] = (commitsByDay[dayName] ?? 0) + count;
    
    _updateStreak(commitDate);
  }

  void recordFeed() => totalFeeds++;
  void recordPlay() => totalPlays++;
  void recordRest() => totalRests++;

  void _updateStreak(DateTime commitDate) {
    if (lastCommitDate == null) {
      currentStreak = 1;
      longestStreak = 1;
    } else {
      final daysDifference = commitDate.difference(lastCommitDate!).inDays;
      
      if (daysDifference == 0) {
        // Same day - keep streak
      } else if (daysDifference == 1) {
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
    lastCommitDate = commitDate;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCommits': totalCommits,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalFeeds': totalFeeds,
      'totalPlays': totalPlays,
      'totalRests': totalRests,
      'commitsByDay': commitsByDay,
      'lastCommitDate': lastCommitDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalCommits: json['totalCommits'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalFeeds: json['totalFeeds'] ?? 0,
      totalPlays: json['totalPlays'] ?? 0,
      totalRests: json['totalRests'] ?? 0,
      commitsByDay: Map<String, int>.from(json['commitsByDay'] ?? {}),
      lastCommitDate: json['lastCommitDate'] != null
          ? DateTime.parse(json['lastCommitDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}