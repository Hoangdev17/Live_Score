import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:livescore/models/MatchDetail.dart';
import '../models/Match.dart';

class MatchService {
  final String apiUrl = 'https://live-score-3h4s.onrender.com/api/matches/live'; 

  Future<List<Match>> fetchMatches() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((match) => Match.fromJson(match)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<Match>> fetchMatchesByCompetition({required int leagueId, required int season}) async {
    final url = Uri.parse('https://live-score-3h4s.onrender.com/api/matches/matchByCompetitions?league=$leagueId&season=$season');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Match.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch matches');
    }
  }

  Future<MatchDetail> fetchMatchDetail(int matchId) async {
    final response = await http.get(Uri.parse('https://live-score-3h4s.onrender.com/api/matches/$matchId'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('API Response: $jsonData');
      return MatchDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load match details');
    }
  }

  // Hàm fetch
  Future<List<dynamic>> fetchFavoriteMatchIds() async {
    final token = await _getToken();
    print('Token: $token');

    if (token == null) return [];

    final response = await http.get(
      Uri.parse('https://live-score-3h4s.onrender.com/api/matches/getfavorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> favorites = jsonResponse['favorites'];

      return favorites;
    } else {
      return [];
    }
  }

  final _storage = const FlutterSecureStorage();
  // Hàm giả định lấy token (bạn thay thế phần này theo code của bạn)
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

}
