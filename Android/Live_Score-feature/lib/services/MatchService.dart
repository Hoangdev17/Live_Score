import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/Match.dart';
import '../models/MatchDetail.dart';

class MatchService {
  final String apiUrl = 'https://live-score-3h4s.onrender.com/api/matches/live';
  final _storage = const FlutterSecureStorage();

  Future<List<Match>> fetchMatches() async {
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((match) => Match.fromJson(match)).toList();
      } else {
        print('Failed to fetch matches: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load matches: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      rethrow;
    }
  }

  Future<List<Match>> fetchMatchesByCompetition({
    required int leagueId,
    required int season,
  }) async {
    final url = Uri.parse('https://live-score-3h4s.onrender.com/api/matches/matchByCompetitions?league=$leagueId&season=$season');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Fetching matches for league $leagueId, season $season: Status ${response.statusCode}');
      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);
        return jsonList.map((e) => Match.fromJson(e)).toList();
      } else {
        print('Failed to fetch matches: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch matches: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      rethrow;
    }
  }

  Future<MatchDetail> fetchMatchDetail(int matchId) async {
    final url = Uri.parse('https://live-score-3h4s.onrender.com/api/matches/$matchId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Fetching match detail for ID $matchId: Status ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response for match $matchId: $jsonData');
        try {
          return MatchDetail.fromJson(jsonData);
        } catch (e) {
          print('Error parsing MatchDetail for match $matchId: $e');
          throw Exception('Failed to parse match details: $e');
        }
      } else {
        print('Failed to fetch match detail for ID $matchId: Status ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load match details: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching match detail for ID $matchId: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchFavoriteMatchIds() async {
    final token = await _getToken();
    if (token == null) {
      print('No token found for fetching favorite matches');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('https://live-score-3h4s.onrender.com/api/matches/getfavorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Fetching favorite matches: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> favorites = jsonResponse['favorites'] ?? [];
        return favorites;
      } else {
        print('Failed to fetch favorite matches: Status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching favorite matches: $e');
      return [];
    }
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}