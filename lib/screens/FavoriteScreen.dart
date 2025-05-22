import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/Match.dart';
import '../screens/MatchDetailScreen.dart';
import '../services/MatchService.dart';
import '../models/MatchDetail.dart';
import '../services/MatchDetailCacheManager.dart';


class FavoriteScreen extends StatefulWidget {
  final List<Match> allMatches;

  const FavoriteScreen({Key? key, required this.allMatches}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Match> favoriteMatches = [];
  Map<int, bool> favoriteStatus = {};
  bool isLoading = false;
  final cacheManager = MatchDetailCacheManager();
  final storage = FlutterSecureStorage();
  final String baseUrl = 'https://live-score-3h4s.onrender.com/api';

  @override
  void initState() {
    super.initState();
    _loadFavoriteMatches();
  }

  Future<String?> _getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<List<dynamic>> fetchFavoriteMatchIds() async {
    try {
      final token = await _getToken();
      print('Token: $token');

      if (token == null) {
        print('No token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/matches/getfavorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Parsed JSON: $jsonResponse');
        return jsonResponse['favorites'] ?? [];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<void> _loadFavoriteMatches() async {
    setState(() => isLoading = true);
    try {
      final favorites = await fetchFavoriteMatchIds();
      List<Match> matches = [];

      if (favorites.isEmpty) {
        setState(() {
          favoriteMatches = [];
          favoriteStatus = {};
          isLoading = false;
        });
        return;
      }

      if (favorites[0] is Map) {
        matches = favorites.map((fav) => Match.fromJson(fav)).toList();
      } else {
        matches = widget.allMatches
            .where((match) => favorites.contains(match.id))
            .toList();
      }

      List<Match> enrichedMatches = [];

      for (var match in matches) {
        try {
          final detail = await cacheManager.getMatchDetail(match.id);

          match.homeTeamLogo = detail.homeLogo;
          match.awayTeamLogo = detail.awayLogo;
          match.homeTeamScore = detail.goals.home;
          match.awayTeamScore = detail.goals.away;
        } catch (e) {
          print('Lỗi khi lấy detail từ cacheManager: $e');
        }

        enrichedMatches.add(match);
      }

      setState(() {
        favoriteMatches = enrichedMatches;
        favoriteStatus = {
          for (var match in enrichedMatches) match.id: true,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải trận yêu thích: $e')),
      );
    }
  }


  Future<void> _toggleFavorite(int matchId) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để quản lý yêu thích')),
      );
      return;
    }

    final isFavorite = favoriteStatus[matchId] ?? false;

    try {
      final url = isFavorite
          ? '$baseUrl/matches/remove'
          : '$baseUrl/matches/addFavoriteMatch';
      final method = isFavorite ? http.delete : http.post;

      final response = await method(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fixtureId': matchId.toString()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isFavorite) {
          // Gỡ yêu thích
          setState(() {
            favoriteMatches.removeWhere((match) => match.id == matchId);
            favoriteStatus.remove(matchId);
          });
        } else {
          // Thêm yêu thích mới
          Match match = widget.allMatches.firstWhere(
                (m) => m.id == matchId,
            orElse: () => Match(
              id: matchId,
              homeTeam: '',
              awayTeam: '',
              utcDate: '',
              competition: '',
              country: '',
              score: '-',
              homeTeamLogo: '',
              awayTeamLogo: '',
              homeTeamScore: 0,
              awayTeamScore: 0,
              status: '',
              venue: '',
            ),
          );

          try {
            final detail = await cacheManager.getMatchDetail(matchId);

            match.homeTeamLogo = detail.homeLogo;
            match.awayTeamLogo = detail.awayLogo;
            match.homeTeamScore = detail.goals.home;
            match.awayTeamScore = detail.goals.away;
          } catch (e) {
            print('Lỗi khi lấy dữ liệu chi tiết matchId $matchId: $e');
          }

          setState(() {
            favoriteMatches.add(match);
            favoriteStatus[matchId] = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? 'Đã xóa khỏi danh sách yêu thích'
                  : 'Đã thêm vào danh sách yêu thích',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception('Lỗi: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật yêu thích: $e')),
      );
    }
  }

  Map<String, List<Match>> groupMatchesByCompetition(List<Match> matches) {
    Map<String, List<Match>> grouped = {};
    for (var match in matches) {
      final comp = match.competition ?? 'Không xác định';
      if (!grouped.containsKey(comp)) {
        grouped[comp] = [];
      }
      grouped[comp]!.add(match);
    }
    return grouped;
  }

  Widget _buildMatchList() {
    final grouped = groupMatchesByCompetition(favoriteMatches);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8),
      children: grouped.entries.expand((entry) {
        final competition = entry.key;
        final compMatches = entry.value;
        return [
          _buildSectionHeader(competition),
          ...compMatches.map((match) => _buildMatchTile(match)).toList(),
          SizedBox(height: 8),
        ];
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String competition) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.orange[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        competition,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailScreen(matchId: match.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                time,
                style: TextStyle(color: Colors.white),
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
                        Icon(Icons.sports_soccer, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.homeTeam,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                isFinished
                    ? '${match.homeTeamScore ?? '-'} - ${match.awayTeamScore ?? '-'}'
                    : '-',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.network(
                    match.awayTeamLogo,
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.sports_soccer, color: Colors.white),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                favoriteStatus[match.id] ?? false
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favoriteStatus[match.id] ?? false ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(match.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('Trận yêu thích'),
        backgroundColor: Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : favoriteMatches.isEmpty
          ? Center(
        child: Text(
          'Chưa có trận yêu thích nào',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : _buildMatchList(),
    );
  }
}