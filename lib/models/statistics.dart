class Statistics {
  final int totalCommits;
  final int currentStreak;
  final int longestStreak;
  final int totalPetInteractions;
  final Map<String, int> commitsByDay;
  final DateTime firstCommitDate;

  Statistics({
    required this.totalCommits,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPetInteractions,
    required this.commitsByDay,
    required this.firstCommitDate,
  });

  factory Statistics.initial() {
    return Statistics(
      totalCommits: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalPetInteractions: 0,
      commitsByDay: {},
      firstCommitDate: DateTime.now(),
    );
  }
}