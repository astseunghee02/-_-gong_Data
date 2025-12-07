import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

class MissionService {
  MissionService._internal();
  static final MissionService instance = MissionService._internal();

  String? get _baseUrl => dotenv.env['API_BASE_URL'];

  Future<Map<String, String>?> _headers() async {
    final token = await AuthService.getToken();
    if (token == null || _baseUrl == null || _baseUrl!.isEmpty) {
      return null;
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<MissionModel>> fetchAvailableMissions() async {
    final headers = await _headers();
    if (headers == null) return [];

    try {
      final res = await http.get(
        Uri.parse('${_baseUrl!}/api/missions/available/'),
        headers: headers,
      );

      if (res.statusCode != 200) return [];

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      return data
          .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ fetchAvailableMissions error: $e');
      return [];
    }
  }

  Future<List<MissionModel>> fetchOngoingMissions() async {
    final headers = await _headers();
    if (headers == null) return [];

    try {
      final res = await http.get(
        Uri.parse('${_baseUrl!}/api/missions/ongoing/'),
        headers: headers,
      );

      if (res.statusCode != 200) return [];

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      return data
          .map((e) => MissionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ fetchOngoingMissions error: $e');
      return [];
    }
  }

  Future<MissionStats?> fetchMissionStats() async {
    final headers = await _headers();
    if (headers == null) return null;

    try {
      final res = await http.get(
        Uri.parse('${_baseUrl!}/api/missions/stats/'),
        headers: headers,
      );

      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      return MissionStats.fromJson(data);
    } catch (e) {
      print('❌ fetchMissionStats error: $e');
      return null;
    }
  }

  Future<void> generateMissions({
    required double lat,
    required double lon,
  }) async {
    final headers = await _headers();
    if (headers == null) return;

    try {
      await http.post(
        Uri.parse('${_baseUrl!}/api/missions/generate/'),
        headers: headers,
        body: json.encode({'lat': lat, 'lon': lon}),
      );
    } catch (e) {
      print('❌ generateMissions error: $e');
    }
  }

  Future<MissionModel?> startMission(
    int missionId, {
    Position? position,
  }) async {
    final headers = await _headers();
    if (headers == null) return null;

    try {
      final res = await http.post(
        Uri.parse('${_baseUrl!}/api/missions/$missionId/start/'),
        headers: headers,
        body: json.encode({
          if (position != null) 'lat': position.latitude,
          if (position != null) 'lon': position.longitude,
        }),
      );

      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      return MissionModel.fromJson(data);
    } catch (e) {
      print('❌ startMission error: $e');
      return null;
    }
  }

  Future<MissionCompletionResult?> completeMission(
    int missionId, {
    Position? position,
  }) async {
    final headers = await _headers();
    if (headers == null) return null;

    try {
      final res = await http.post(
        Uri.parse('${_baseUrl!}/api/missions/$missionId/complete/'),
        headers: headers,
        body: json.encode({
          if (position != null) 'lat': position.latitude,
          if (position != null) 'lon': position.longitude,
        }),
      );

      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      return MissionCompletionResult.fromJson(data);
    } catch (e) {
      print('❌ completeMission error: $e');
      return null;
    }
  }
}

class MissionModel {
  final int userMissionId;
  final int missionId;
  final String title;
  final String description;
  final String difficulty;
  final int points;
  final String status;
  final double? distanceKm;
  final String? placeName;
  final String? address;

  MissionModel({
    required this.userMissionId,
    required this.missionId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.points,
    required this.status,
    this.distanceKm,
    this.placeName,
    this.address,
  });

  bool get isAvailable => status == 'available';
  bool get isOngoing => status == 'ongoing';

  String get pointText => '+${points}P';

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    final mission = json['mission'] as Map<String, dynamic>? ?? {};
    final place = mission['place_info'] as Map<String, dynamic>? ?? {};

    return MissionModel(
      userMissionId: json['id'] as int? ?? mission['id'] as int? ?? 0,
      missionId: mission['id'] as int? ?? json['mission_id'] as int? ?? 0,
      title: mission['title'] as String? ?? '',
      description: mission['description'] as String? ?? '',
      difficulty: mission['difficulty'] as String? ?? 'normal',
      points: (mission['total_points'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      distanceKm: (json['distance_from_user'] as num?)?.toDouble(),
      placeName: place['name'] as String?,
      address: place['address'] as String?,
    );
  }
}

class MissionStats {
  final int ongoing;
  final int weeklyCompleted;
  final int totalCompleted;

  MissionStats({
    required this.ongoing,
    required this.weeklyCompleted,
    required this.totalCompleted,
  });

  factory MissionStats.fromJson(Map<String, dynamic> json) {
    return MissionStats(
      ongoing: json['ongoing'] as int? ?? 0,
      weeklyCompleted: json['weekly_completed'] as int? ?? 0,
      totalCompleted: json['total_completed'] as int? ?? 0,
    );
  }
}

class MissionCompletionResult {
  final int pointsEarned;
  final MissionModel mission;

  MissionCompletionResult({
    required this.pointsEarned,
    required this.mission,
  });

  factory MissionCompletionResult.fromJson(Map<String, dynamic> json) {
    return MissionCompletionResult(
      pointsEarned: json['points_earned'] as int? ?? 0,
      mission: MissionModel.fromJson(json['mission'] as Map<String, dynamic>? ?? {}),
    );
  }
}
