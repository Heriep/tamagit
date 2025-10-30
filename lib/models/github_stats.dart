class GitHubStats {
  final int commitCount;
  final int pullRequestCount;
  final int issuesCount;
  final DateTime fetchedAt;
  final List<CommitInfo> recentCommits;

  GitHubStats({
    required this.commitCount,
    this.pullRequestCount = 0,
    this.issuesCount = 0,
    required this.fetchedAt,
    this.recentCommits = const [],
  });

  factory GitHubStats.fromJson(Map<String, dynamic> json) {
    return GitHubStats(
      commitCount: json['commit_count'] ?? 0,
      pullRequestCount: json['pull_request_count'] ?? 0,
      issuesCount: json['issues_count'] ?? 0,
      fetchedAt: DateTime.parse(json['fetched_at']),
      recentCommits: (json['recent_commits'] as List?)
              ?.map((c) => CommitInfo.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commit_count': commitCount,
      'pull_request_count': pullRequestCount,
      'issues_count': issuesCount,
      'fetched_at': fetchedAt.toIso8601String(),
      'recent_commits': recentCommits.map((c) => c.toJson()).toList(),
    };
  }

  // Calculate "food value" for the pet
  int get foodValue {
    return (commitCount * 10) + (pullRequestCount * 15) + (issuesCount * 5);
  }
}

class CommitInfo {
  final String sha;
  final String message;
  final DateTime date;
  final int additions;
  final int deletions;

  CommitInfo({
    required this.sha,
    required this.message,
    required this.date,
    this.additions = 0,
    this.deletions = 0,
  });

  factory CommitInfo.fromJson(Map<String, dynamic> json) {
    return CommitInfo(
      sha: json['sha'] ?? '',
      message: json['message'] ?? '',
      date: DateTime.parse(json['date']),
      additions: json['additions'] ?? 0,
      deletions: json['deletions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sha': sha,
      'message': message,
      'date': date.toIso8601String(),
      'additions': additions,
      'deletions': deletions,
    };
  }

  // Calculate impact score based on diff size
  int get impactScore {
    return additions + deletions;
  }
}