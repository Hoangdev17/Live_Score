import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Competition.dart';

class CompetitionService {
  final String apiUrl = 'http://192.168.100.104:5000/api/matches/competitions';

  Future<List<Competition>> fetchCompetitions() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Competition.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load competitions');
    }
  }
}
