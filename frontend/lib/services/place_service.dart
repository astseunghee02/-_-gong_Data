import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PlaceService {
  PlaceService._internal();
  static final PlaceService instance = PlaceService._internal();

  Future<List<NearbyPlace>> fetchNearbyPlaces({
    required Position position,
    int limit = 5,
  }) async {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$baseUrl/api/nearby?lat=${position.latitude}&lon=${position.longitude}&limit=$limit',
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];

      final List<dynamic> data = json.decode(res.body) as List<dynamic>;
      return data
          .map((e) => NearbyPlace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ fetchNearbyPlaces 오류: $e');
      return [];
    }
  }
}

class NearbyPlace {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;

  NearbyPlace({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
    );
  }
}
