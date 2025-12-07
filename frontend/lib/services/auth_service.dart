import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _profileCacheKey = 'profile_cache';
  static const String _profileNameKey = 'profile_name';
  static const String _profileLevelKey = 'profile_level';

  // 토큰 저장
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 토큰 가져오기
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 사용자 정보 저장
  static Future<void> saveUserInfo(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  static Future<void> _cacheProfileData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileCacheKey, json.encode(data));

    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    final name = (profile['name'] as String?)?.trim();
    final username = data['username'] as String?;
    final level = profile['level'];

    if (name != null && name.isNotEmpty) {
      await prefs.setString(_profileNameKey, name);
    } else if (username != null) {
      await prefs.setString(_profileNameKey, username);
    }

    if (level is int) {
      await prefs.setInt(_profileLevelKey, level);
    }
  }

  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_profileCacheKey);
    if (cached == null) return null;

    try {
      return json.decode(cached) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCachedProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileNameKey);
  }

  static Future<int?> getCachedProfileLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileLevelKey);
  }

  static Future<void> cacheProfile(Map<String, dynamic> data) async {
    await _cacheProfileData(data);
  }

  // 사용자 이름 가져오기
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // 로그아웃 (토큰 및 사용자 정보 삭제)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }

  // 사용자 프로필 가져오기
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final cachedProfile = await getCachedProfile();
    final token = await getToken();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (token == null || baseUrl == null || baseUrl.isEmpty) {
      return cachedProfile;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        await _cacheProfileData(decoded);
        return decoded;
      }
      return cachedProfile;
    } catch (e) {
      print('프로필 조회 오류: $e');
      return cachedProfile;
    }
  }

  // 사용자 프로필 업데이트
  static Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    final token = await getToken();
    if (token == null) return false;

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/profile/update/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      final success = response.statusCode == 200;
      if (success) {
        // 최신 데이터를 다시 가져와 캐시에 반영
        await getUserProfile();
      }
      return success;
    } catch (e) {
      print('프로필 업데이트 오류: $e');
      return false;
    }
  }
}
