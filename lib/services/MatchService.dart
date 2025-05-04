import 'dart:convert';
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

}
