import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Competition.dart';
import '../models/Match.dart';

class CompetitionService {
  final String baseUrl = 'https://live-score-3h4s.onrender.com/api/matches';

  Future<List<Competition>> fetchCompetitions({int page = 1, int perPage = 20}) async {
    final url = Uri.parse('$baseUrl/competitions?page=$page&per_page=$perPage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      // Xử lý cả hai trường hợp API trả về trực tiếp mảng hoặc object có thuộc tính data
      final List data = body is List ? body : body['data'] ?? [];

      return data.map((json) => Competition.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load competitions. Status code: ${response.statusCode}');
    }
  }

  Future<List<Match>> fetchMatchesByCompetition({
    required int leagueId,
    required int season,
  }) async {
    final url = Uri.parse(
        '$baseUrl/matchByCompetitions?league=$leagueId&season=$season'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Match.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch matches. Status code: ${response.statusCode}');
    }
  }
}