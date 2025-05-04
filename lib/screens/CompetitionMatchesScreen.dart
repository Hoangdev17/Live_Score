import 'package:flutter/material.dart';
import 'package:livescore/models/Competition.dart';
import '../models/Match.dart';
import '../services/MatchService.dart';

class CompetitionMatchesScreen extends StatefulWidget {
  final int leagueId;
  final int season;
  final String leagueName;
  final String logo; // ✅ Add this

  CompetitionMatchesScreen({
    required this.leagueId,
    required this.season,
    required this.leagueName,
    required this.logo, // ✅ Add this
  });

  @override
  _CompetitionMatchesScreenState createState() =>
      _CompetitionMatchesScreenState();
}

class _CompetitionMatchesScreenState extends State<CompetitionMatchesScreen> {
  bool isLoading = true;
  List<Match> matches = [];

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
      setState(() {
        matches = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải trận đấu: $e')),
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
                ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent))
                : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _buildMatchTile(match);
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

    // 👇 Log the match info to debug score rendering
    print(
        'Match: ${match.homeTeam} vs ${match.awayTeam} | Status: ${match.status} | Score: ${match.homeTeamScore} - ${match.awayTeamScore}'
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Time or status
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Home Team
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
          // Score
          Expanded(
            flex: 2,
            child: Text(
              isFinished
                  ? '${match.homeTeamScore} - ${match.awayTeamScore}'
                  : '-',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          // Away Team
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
        ],
      ),
    );
  }
}
