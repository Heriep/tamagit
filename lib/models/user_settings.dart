class UserSettings {
  String? githubUsername;
  String? githubToken;
  bool notificationsEnabled;
  int checkIntervalMinutes;
  DateTime? lastChecked;
  Set<String> usedCommitShas;

  UserSettings({
    this.githubUsername,
    this.githubToken,
    this.notificationsEnabled = true,
    this.checkIntervalMinutes = 60,
    this.lastChecked,
    Set<String>? usedCommitShas,
  }) : usedCommitShas = usedCommitShas ?? {};

  bool get isConfigured => githubUsername != null && githubUsername!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'githubUsername': githubUsername,
      'githubToken': githubToken,
      'notificationsEnabled': notificationsEnabled,
      'checkIntervalMinutes': checkIntervalMinutes,
      'lastChecked': lastChecked?.toIso8601String(),
      'usedCommitShas': usedCommitShas.toList(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      githubUsername: json['githubUsername'],
      githubToken: json['githubToken'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      checkIntervalMinutes: json['checkIntervalMinutes'] ?? 60,
      lastChecked: json['lastChecked'] != null
          ? DateTime.parse(json['lastChecked'])
          : null,
      usedCommitShas: json['usedCommitShas'] != null
          ? Set<String>.from(json['usedCommitShas'])
          : {},
    );
  }
}