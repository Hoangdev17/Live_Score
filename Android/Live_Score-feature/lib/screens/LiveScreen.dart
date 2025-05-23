import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livescore/screens/MatchDetailScreen.dart';
import '../models/Match.dart';
import '../services/MatchService.dart';
import '../utils/utils.dart';
import 'dart:math'; // Import for Random

class LiveScreen extends StatefulWidget {
  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  late StreamController<List<Match>> _streamController;
  List<Match> matches = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? _scoreUpdateTimer; // Keep a reference to the timer for cancellation
  final Random _random = Random(); // Initialize Random once

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<Match>>.broadcast();
    _fetchLiveMatches();
  }

  // Lấy và phát dữ liệu trận đấu
  void _fetchLiveMatches() async {
    setState(() { // Show loading state immediately on retry
      isLoading = true;
      errorMessage = null;
    });
    try {
      matches = await MatchService().fetchMatches();
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
      _streamController.add(matches);
      print('Loaded ${matches.length} matches');
      _startScoreUpdates(); // Start updates after successful fetch
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi tải trận đấu: $e';
      });
      _streamController.addError(e);
      print('Error loading matches: $e');
    }
  }

  // Cập nhật điểm số ngẫu nhiên
  void _startScoreUpdates() {
    // Cancel any existing timer to avoid multiple timers running
    _scoreUpdateTimer?.cancel();
    _scoreUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) { // Reduced interval for more dynamic feel, adjust as needed
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Optimization 1: Only update a subset of matches, or update them intelligently
      // For a more realistic live score, you'd likely have a backend pushing updates
      // Here, we simulate by updating a few random matches or all if few.
      final int matchesToUpdate = min(matches.length, (matches.length * 0.2).ceil() + 1); // Update at least 1, up to 20%
      Set<int> updatedIndices = {};

      while (updatedIndices.length < matchesToUpdate) {
        int index = _random.nextInt(matches.length);
        if (!updatedIndices.contains(index)) {
          matches[index].score = _generateRandomScore();
          updatedIndices.add(index);
        }
      }

      // Optimization 2: Use a separate stream for score updates if possible, or
      // only add to the main stream if actual changes occurred.
      // For simplicity and given the current structure, adding to the main stream is still used.
      _streamController.add(matches);
      print('Updated scores for ${updatedIndices.length} random matches');
    });
  }

  // Hàm tạo điểm số ngẫu nhiên
  String _generateRandomScore() {
    // Optimization 3: More realistic random score generation
    int homeScore = _random.nextInt(5); // Scores from 0 to 4
    int awayScore = _random.nextInt(5);
    return "$homeScore - $awayScore";
  }

  // Nhóm các trận đấu theo giải đấu
  Map<String, List<Match>> groupMatchesByCompetition(List<Match> matches) {
    final Map<String, List<Match>> grouped = {};
    for (var match in matches) {
      grouped.putIfAbsent(match.competition, () => []).add(match);
    }
    return grouped;
  }

  @override
  void dispose() {
    _scoreUpdateTimer?.cancel(); // Cancel the timer when the widget is disposed
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Match>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError || errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage ?? 'Đã xảy ra lỗi', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLiveMatches,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Không có trận đấu trực tiếp', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLiveMatches,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Tải lại'),
                  ),
                ],
              ),
            );
          }

          final grouped = groupMatchesByCompetition(snapshot.data!);
          return ListView.separated(
            cacheExtent: 1000.0,
            itemCount: grouped.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              String competition = grouped.keys.elementAt(index);
              List<Match> compMatches = grouped[competition]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(competition),
                  ...compMatches.map((match) => _buildMatchTile(match)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Header cho mỗi giải đấu
  Widget _buildSectionHeader(String competition) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          competition,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Tiêu đề trận đấu
  Widget _buildMatchTile(Match match) {
    final matchStatus = _getMatchStatus(match.utcDate);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailScreen(matchId: match.id)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatUtcDate(match.utcDate) ?? '00:00',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    match.homeTeam,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    match.awayTeam,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: matchStatus == 'LIVE' ? Colors.redAccent : Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      matchStatus == 'LIVE' ? 'Đang diễn ra' : matchStatus == 'FINISHED' ? 'Kết thúc' : 'Sắp diễn ra',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    match.score,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('1.36', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('4.75', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('8.50', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Xác định trạng thái trận đấu
  String _getMatchStatus(String utcDate) {
    final matchDate = DateTime.parse(utcDate).toLocal();
    final now = DateTime.now();
    final duration = matchDate.difference(now);
    if (duration.inMinutes > 0) {
      return 'UPCOMING';
    } else if (duration.inMinutes > -90) {
      return 'LIVE';
    } else {
      return 'FINISHED';
    }
  }
}