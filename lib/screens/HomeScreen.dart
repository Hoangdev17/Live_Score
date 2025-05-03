import 'package:flutter/material.dart';
import 'package:livescore/screens/CompetitionScreen.dart';
import 'package:livescore/screens/LiveScreen.dart';
import '../models/Match.dart';
import '../services/MatchService.dart';
import '../utils/utils.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  List<Match> matches = [];
  List<Match> liveMatches = [];
  int selectedIndex = 0;
  late StreamController<List<Match>> _liveMatchController;
  StreamSubscription<List<Match>>? _liveMatchSubscription;
  bool _hasLoadedMatches = false; // Track if matches are already loaded
  bool _hasLoadedLiveMatches = false; // Track if live matches are loaded

  @override
  void initState() {
    super.initState();
    _liveMatchController = StreamController<List<Match>>.broadcast();
    if (selectedIndex == 0 || selectedIndex == 3) {
      _loadMatches();
    }
  }

  Future<void> _loadMatches() async {
    if (_hasLoadedMatches) return; // Skip if already loaded
    setState(() => isLoading = true);
    try {
      final newMatches = await MatchService().fetchMatches();
      setState(() {
        matches = newMatches;
        liveMatches = List.from(newMatches); // Create a copy for live updates
        _hasLoadedMatches = true;
      });
      _liveMatchController.add(liveMatches); // Update stream with initial data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách trận: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Stream<List<Match>> _fetchLiveMatches() {
    Timer? timer;
    if (!_hasLoadedLiveMatches) {
      timer = Timer.periodic(Duration(seconds: 15), (t) {
        // Update every 15s instead of 10s to reduce load
        for (var match in liveMatches) {
          match.score = _generateRandomScore();
        }
        _liveMatchController.add(List.from(liveMatches));
      });
      _hasLoadedLiveMatches = true;
    }
    return _liveMatchController.stream;
  }

  String _generateRandomScore() {
    int homeScore = (1 + (2 - 1) * (0 + 1)).toInt();
    int awayScore = (1 + (2 - 1) * (0 + 1)).toInt();
    return "$homeScore - $awayScore";
  }

  Map<String, List<Match>> groupMatchesByCompetition(List<Match> matches) {
    return Map.fromIterable(
      matches,
      key: (match) => match.competition,
      value: (match) => matches.where((m) => m.competition == match.competition).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Color(0xFF121212),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thích', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[700],
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
              if ((index == 0 || index == 3) && !_hasLoadedMatches) {
                _loadMatches();
              }
              if (index == 1 && !_hasLoadedLiveMatches) {
                _liveMatchSubscription = _fetchLiveMatches().listen((data) {
                  _liveMatchController.add(data);
                });
              }
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer, size: 28), label: 'Tất cả'),
            BottomNavigationBarItem(icon: Icon(Icons.live_tv, size: 28), label: 'Trực tiếp'),
            BottomNavigationBarItem(icon: Icon(Icons.star_border, size: 28), label: 'Gợi ý'),
            BottomNavigationBarItem(icon: Icon(Icons.star, size: 28), label: 'Thích'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events, size: 28), label: 'Giải đấu'),
          ],
        ),
        body: _buildTabContent(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _buildMatchList();
      case 1:
        return LiveScreen();
      case 2:
        return Center(child: Text('Gợi ý content'));
      case 3:
        return isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _buildMatchList();
      case 4:
        return CompetitionScreen();
      default:
        return isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _buildMatchList();
    }
  }

  Widget _buildMatchList() {
    final grouped = groupMatchesByCompetition(matches);
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

  Widget _buildLiveMatchList(List<Match> matches) {
    final grouped = groupMatchesByCompetition(matches);
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: EdgeInsets.all(16),
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
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Đang diễn ra',
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
    );
  }

  @override
  void dispose() {
    _liveMatchController.close();
    _liveMatchSubscription?.cancel();
    super.dispose();
  }
}