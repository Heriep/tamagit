import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_stats.dart';

class GitHubService {
  static const String baseUrl = 'https://api.github.com';
  String? _token;
  String? _username;

  void setCredentials(String username, String? token) {
    _username = username;
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'token $_token';
    }
    return headers;
  }

  Future<GitHubStats> fetchRecentCommits({int days = 1}) async {
    if (_username == null || _username!.isEmpty) {
      throw Exception('GitHub username not configured');
    }

    final since = DateTime.now().subtract(Duration(days: days));
    final sinceIso = since.toIso8601String();
    
    // Search for commits by this user
    final url = Uri.parse(
      '$baseUrl/search/commits?q=author:$_username+committer-date:>$sinceIso&sort=committer-date&order=desc',
    );

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final commits = <CommitInfo>[];

        // Parse recent commits
        if (data['items'] != null) {
          for (var item in (data['items'] as List).take(10)) {
            try {
              commits.add(CommitInfo(
                sha: item['sha'] ?? '',
                message: item['commit']?['message'] ?? 'No message',
                date: DateTime.parse(
                  item['commit']?['committer']?['date'] ?? DateTime.now().toIso8601String(),
                ),
              ));
            } catch (e) {
              // Skip malformed commits
              continue;
            }
          }
        }

        return GitHubStats(
          commitCount: data['total_count'] ?? 0,
          fetchedAt: DateTime.now(),
          recentCommits: commits,
        );
      } else if (response.statusCode == 422) {
        // Validation failed - likely no commits
        return GitHubStats(
          commitCount: 0,
          fetchedAt: DateTime.now(),
          recentCommits: [],
        );
      } else {
        throw Exception('Failed to fetch commits: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserInfo() async {
    if (_username == null || _username!.isEmpty) {
      throw Exception('GitHub username not configured');
    }

    final url = Uri.parse('$baseUrl/users/$_username');

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('User not found: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user info: $e');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      await fetchUserInfo();
      return true;
    } catch (e) {
      return false;
    }
  }
}