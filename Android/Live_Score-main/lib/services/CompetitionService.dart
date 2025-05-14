import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Competition.dart';
import '../models/Match.dart';

class CompetitionService {
  final String apiUrl = 'https://live-score-3h4s.onrender.com/api/matches/competitions';

  Future<List<Competition>> fetchCompetitions() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Competition.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load competitions');
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
}
