import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Match.dart';

class MatchService {
  final String apiUrl = 'https://live-score-3h4s.onrender.com/api/matches/live'; // Địa chỉ API của backend Node.js

  Future<List<Match>> fetchMatches() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((match) => Match.fromJson(match)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }
}
