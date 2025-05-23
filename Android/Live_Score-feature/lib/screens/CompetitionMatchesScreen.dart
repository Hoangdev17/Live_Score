import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage for better image handling

import '../models/Match.dart';
import '../services/MatchService.dart';
import '../screens/MatchDetailScreen.dart';

final _storage = const FlutterSecureStorage();

Future<String?> _getToken() async {
  return await _storage.read(key: 'jwt_token');
}

class CompetitionMatchesScreen extends StatefulWidget {
  final int leagueId;
  final int season;
  final String leagueName;
  final String logo;

  const CompetitionMatchesScreen({ // Added const
    required this.leagueId,
    required this.season,
    required this.leagueName,
    required this.logo,
    Key? key, // Added Key
  }) : super(key: key); // Pass key to super

  @override
  _CompetitionMatchesScreenState createState() =>
      _CompetitionMatchesScreenState();
}

class _CompetitionMatchesScreenState extends State<CompetitionMatchesScreen>
    with SingleTickerProviderStateMixin { // Added SingleTickerProviderStateMixin for TabController
  bool isLoading = true;
  List<Match> matches = [];
  Map<int, bool> favoriteMatches = {};
  TabController? _tabController; // Declare TabController
  final List<String> tabs = ['Tất cả', 'Do ván', 'Các trận đấu', 'Dữ liệu trực thu'];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this); // Initialize TabController
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Dispose TabController
    super.dispose();
  }

  Future<void> _loadMatches() async {
    try {
      setState(() => isLoading = true); // Set loading true at the start
      final initialMatches = await MatchService().fetchMatchesByCompetition(
        leagueId: widget.leagueId,
        season: widget.season,
      );

      final favoriteIds = await _fetchFavoriteMatches();

      // Fetch details for each match concurrently
      final detailedMatches = await Future.wait(
        initialMatches.map((match) async {
          try {
            final detail = await MatchService().fetchMatchDetail(match.id);
            return match.copyWith(
              homeTeamLogo: detail.homeLogo,
              awayTeamLogo: detail.awayLogo,
              homeTeamScore: detail.goals.home,
              awayTeamScore: detail.goals.away,
              score: '${detail.goals.home} - ${detail.goals.away}',
              status: detail.status,
            );
          } catch (e) {
            print('Error loading detail for match ${match.id}: $e');
            // If detail fetching fails, return the original match without updated info
            return match;
          }
        }),
      );

      setState(() {
        matches = detailedMatches;
        favoriteMatches = {
          for (var match in matches)
            match.id: favoriteIds.contains(match.id),
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error loading matches: $e'); // Print detailed error for debugging
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể tải danh sách trận đấu. Vui lòng kiểm tra kết nối và thử lại.'),
          action: SnackBarAction(
            label: 'Thử lại',
            onPressed: _loadMatches,
          ),
        ),
      );
    }
  }

  Future<List<int>> _fetchFavoriteMatches() async {
    final token = await _getToken();
    if (token == null) return [];

    try { // Added try-catch for network requests
      final response = await http.get(
        Uri.parse('https://live-score-3h4s.onrender.com/api/matches/getfavorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10)); // Add timeout for network requests

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic> && jsonResponse['favorites'] is List) {
          return (jsonResponse['favorites'] as List)
              .where((match) => match['id'] is int) // Ensure 'id' is an int
              .map((match) => match['id'] as int)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<void> _toggleFavorite(int matchId) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tiếp tục')), // More user-friendly message
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
            duration: const Duration(seconds: 2), // Increased duration
          ),
        );
      } else if (response.statusCode == 401) { // Handle unauthorized specifically
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.')),
        );
      }
      else {
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
            CachedNetworkImage( // Use CachedNetworkImage for league logo
              imageUrl: widget.logo,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(), // Placeholder
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
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
                    'Châu Âu / 16.7B€ • 146809 Nguồn theo dõi', // This is static text
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
        bottom: TabBar( // Integrate TabBar with TabController
          controller: _tabController,
          tabs: tabs.map((title) => Tab(text: title)).toList(),
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView( // Use TabBarView to show content for each tab
        controller: _tabController,
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return InkWell(
                key: ValueKey(match.id), // Add a key for better list performance
                onTap: () {
                  // Use rootNavigator: true to push to new route outside current navigator if needed
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => MatchDetailScreen(matchId: match.id),
                    ),
                  );
                },
                child: _buildMatchTile(match),
              );
            },
          ),
          const Center(child: Text('Do ván - Coming soon', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Các trận đấu - Coming soon', style: TextStyle(color: Colors.white))),
          const Center(child: Text('Dữ liệu trực thu - Coming soon', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  // Renamed _buildTab to be consistent with removed TabBar widgets in AppBar
  // This _buildTab was for a custom row of tabs, now using native TabBar
  // Widget _buildTab(String title, bool isActive) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10),
  //     child: Text(
  //       title,
  //       style: TextStyle(
  //         color: isActive ? Colors.blue : Colors.white,
  //         fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
  //         fontSize: 14,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMatchTile(Match match) {
    // Determine if the match is finished or live based on its status
    final isFinished = ['finished', 'completed', 'ft', 'match finished']
        .any((s) => match.status.toLowerCase().contains(s));
    final isLive = ['live', 'in progress', 'first half', 'second half', 'penalties']
        .any((s) => match.status.toLowerCase().contains(s));


    final time = isFinished
        ? 'Hết'
        : isLive
        ? 'Live' // Display "Live" for live matches
        : match.utcDate.contains('T')
        ? match.utcDate.split('T')[1].substring(0, 5) // Format time for scheduled matches
        : match.utcDate; // Fallback if no 'T' separator

    // Determine the score or status to display
    final scoreOrStatus = isFinished || isLive
        ? (match.score.isNotEmpty // Use match.score directly if it's set
        ? match.score
        : (match.homeTeamScore != null && match.awayTeamScore != null // Fallback to individual scores
        ? '${match.homeTeamScore} - ${match.awayTeamScore}'
        : '-')) // Display '-' if scores are null
        : '-'; // Display '-' for scheduled matches without a score

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
              style: TextStyle(
                color: isLive ? Colors.red : Colors.white, // Red for live matches
                fontWeight: isLive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CachedNetworkImage( // Use CachedNetworkImage for team logos
                  imageUrl: match.homeTeamLogo,
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                  errorWidget: (ctx, url, err) =>
                  const Icon(Icons.sports_soccer, color: Colors.white), // Default icon on error
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
              scoreOrStatus, // Display the calculated score or status
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLive ? Colors.red : Colors.white, // Red for live match scores
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
                CachedNetworkImage( // Use CachedNetworkImage for team logos
                  imageUrl: match.awayTeamLogo,
                  height: 28,
                  width: 28,
                  fit: BoxFit.contain,
                  errorWidget: (ctx, url, err) =>
                  const Icon(Icons.sports_soccer, color: Colors.white), // Default icon on error
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