import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livescore/models/Competition.dart';
import '../models/Match.dart';
import '../services/MatchService.dart';
import '../screens/MatchDetailScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final _storage = const FlutterSecureStorage();

Future<String?> _getToken() async {
  return await _storage.read(key: 'jwt_token');
}

class CompetitionMatchesScreen extends StatefulWidget {
  final int leagueId;
  final int season;
  final String leagueName;
  final String logo;

  CompetitionMatchesScreen({
    required this.leagueId,
    required this.season,
    required this.leagueName,
    required this.logo,
  });

  @override
  _CompetitionMatchesScreenState createState() =>
      _CompetitionMatchesScreenState();
}

class _CompetitionMatchesScreenState extends State<CompetitionMatchesScreen> {
  bool isLoading = true;
  List<Match> matches = [];
  Map<int, bool> favoriteMatches = {};

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final data = await MatchService().fetchMatchesByCompetition(
        leagueId: widget.leagueId,
        season: widget.season,
      );

      final favoriteIds = await _fetchFavoriteMatches();

      setState(() {
        matches = data;
        favoriteMatches = {
          for (var match in matches)
            match.id: favoriteIds.contains(match.id),
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải trận đấu: $e')),
      );
    }
  }

  Future<List<int>> _fetchFavoriteMatches() async {
    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('https://live-score-3h4s.onrender.com/api/matches/getfavorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> favorites = jsonResponse['favorites'];
      // Lấy list id từ từng object trong favorites
      final List<int> favoriteIds = favorites.map<int>((match) => match['id'] as int).toList();
      return favoriteIds;
    } else {
      return [];
    }
  }

  Future<void> _toggleFavorite(int matchId) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập')),
      );
      return;
    }

    final currentlyFavorite = favoriteMatches[matchId] ?? false;

    final url = currentlyFavorite
        ? 'https://live-score-3h4s.onrender.com/api/matches/remove'
        : 'https://live-score-3h4s.onrender.com/api/matches/addFavoriteMatch';

    try {
      final response = currentlyFavorite
          ? await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fixtureId': matchId}),
      )
          : await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fixtureId': matchId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteMatches[matchId] = !currentlyFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentlyFavorite
                ? 'Đã xóa khỏi danh sách yêu thích'
                : 'Đã thêm vào danh sách yêu thích'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2A3A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2A3A),
        elevation: 0,
        title: Row(
          children: [
            Image.network(
              widget.logo,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.leagueName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Châu Âu / 16.7B€ • 146809 Nguồn theo dõi',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Tất cả', true),
                _buildTab('Do ván', false),
                _buildTab('Các trận đấu', false),
                _buildTab('Dữ liệu trực thu', false),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchDetailScreen(matchId: match.id),
                      ),
                    );
                  },
                  child: _buildMatchTile(match),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.blue : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMatchTile(Match match) {
    final isFinished = match.status.toLowerCase().contains('finished');
    final time = isFinished
        ? 'Hết'
        : match.utcDate.contains('T')
        ? match.utcDate.split('T')[1].substring(0, 5)
        : match.utcDate;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Image.network(
                  match.homeTeamLogo,
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.sports_soccer, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    match.homeTeam,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              isFinished
                  ? '${match.homeTeamScore} - ${match.awayTeamScore}'
                  : '-',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    match.awayTeam,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Image.network(
                  match.awayTeamLogo,
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.sports_soccer, color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              favoriteMatches[match.id] ?? false
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favoriteMatches[match.id] ?? false ? Colors.red : Colors.grey,
            ),
            onPressed: () => _toggleFavorite(match.id),
          ),
        ],
      ),
    );
  }
}