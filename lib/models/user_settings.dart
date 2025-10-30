class UserSettings {
  String? githubUsername;
  String? githubToken;
  bool notificationsEnabled;
  int checkIntervalMinutes;
  DateTime? lastChecked;

  UserSettings({
    this.githubUsername,
    this.githubToken,
    this.notificationsEnabled = true,
    this.checkIntervalMinutes = 60,
    this.lastChecked,
  });

  bool get isConfigured => githubUsername != null && githubUsername!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'githubUsername': githubUsername,
      'githubToken': githubToken,
      'notificationsEnabled': notificationsEnabled,
      'checkIntervalMinutes': checkIntervalMinutes,
      'lastChecked': lastChecked?.toIso8601String(),
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
    );
  }
}