import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Competition.dart';
import '../models/Match.dart';

class CompetitionService {
  final String apiUrl = 'https://live-score-3h4s.onrender.com/api/matches/competitions';

  List<Competition>? _cachedCompetitions;

  Future<List<Competition>> fetchCompetitions({int page = 1, int pageSize = 10}) async {
    if (_cachedCompetitions == null) {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _cachedCompetitions = data.map((json) => Competition.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load competitions');
      }
    }

    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    if (start >= _cachedCompetitions!.length) return [];

    return _cachedCompetitions!.sublist(start, end.clamp(0, _cachedCompetitions!.length));
  }

  Future<List<Match>> fetchMatchesByCompetition({
    required int leagueId,
    required int season,
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse('https://live-score-3h4s.onrender.com/api/matches/matchByCompetitions?league=$leagueId&season=$season');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) {
        final fixture = e['fixture'] ?? {};
        final teams = e['teams'] ?? {};
        final goals = e['goals'] ?? {};
        final league = e['league'] ?? {};

        return Match(
          id: fixture['id'] ?? 0,
          homeTeam: teams['home']?['name'] ?? 'Unknown',
          awayTeam: teams['away']?['name'] ?? 'Unknown',
          utcDate: fixture['date'] ?? '',
          competition: league['name'] ?? '',
          country: league['country'] ?? '',
          score: '${goals['home'] ?? 0} - ${goals['away'] ?? 0}',
          homeTeamLogo: teams['home']?['logo'] ?? '',
          awayTeamLogo: teams['away']?['logo'] ?? '',
          homeTeamScore: goals['home'] ?? 0,
          awayTeamScore: goals['away'] ?? 0,
          status: fixture['status']?['short'] ?? 'NS',
          venue: fixture['venue']?['name'] ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch matches');
    }
  }
}