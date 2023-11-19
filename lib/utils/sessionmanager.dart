import 'package:shared_preferences/shared_preferences.dart';

/// A class to manage session tokens in shared preferences. Used for
/// keeping track of logged in users in eg3
class SessionManager {
  static const String _sessionKey = 'sessionToken';
  static const String _username = 'username';

  // Method to check if a user is logged in (has an active session).
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString(_sessionKey);
    return sessionToken != null;
  }

  // Method to retrieve the session token.
  static Future<String> getSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey) ?? '';
  }

  static Future<String> getSessionUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_username) ?? '';
  }

  // Method to set the session token. 
  static Future<void> setSessionToken(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, "Bearer $token");
    await prefs.setString(_username, username);
  }

  // Method to clear the session token, effectively logging the user out.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_username);
  }
}
