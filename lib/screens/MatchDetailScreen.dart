import 'package:flutter/material.dart';
import '../models/MatchDetail.dart';
import '../services/MatchService.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  MatchDetailScreen({required this.matchId});

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MatchDetail? match;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0); // Default to the "Trận đấu" tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to get statistic value for a specific team
  dynamic _getStatisticValue(String type, String teamName, List<Statistics> statistics) {
    final teamStats = statistics.firstWhere(
          (stat) => stat.team.name == teamName,
      orElse: () => Statistics(team: Team(id: 0, name: '', logo: ''), statistics: []),
    );
    final stat = teamStats.statistics.firstWhere(
          (stat) => stat.type == type,
      orElse: () => StatisticDetail(type: '', value: null),
    );
    return stat.value ?? 0;
  }

  // Get goal scorer from events
  String _getGoalScorer(List<Event> events) {
    final goalEvents = events.where((event) => event.type == 'Goal').toList();
    if (goalEvents.isNotEmpty) {
      return '${goalEvents.first.player.name} (${goalEvents.first.time.elapsed}′)';
    }
    return '';
  }

  // Helper method to format event time
  String _formatEventTime(Event event) {
    final extraTime = event.time.extra != null ? '+${event.time.extra}' : '';
    return '${event.time.elapsed}$extraTime′';
  }

  // Helper method to display event details
  Widget _buildEventRow(Event event) {
    String eventDescription = '';
    IconData eventIcon;
    Color iconColor;

    switch (event.type) {
      case 'Goal':
        eventDescription = '${event.player.name} (Assist: ${event.assist?.name ?? 'N/A'})';
        eventIcon = Icons.sports_soccer;
        iconColor = Colors.green;
        break;
      case 'subst':
        eventDescription = 'Thay người: ${event.player.name} ra, ${event.assist?.name ?? 'N/A'} vào';
        eventIcon = Icons.swap_horiz;
        iconColor = Colors.blue;
        break;
      case 'Card':
        eventDescription = '${event.detail} - ${event.player.name} (${event.comments ?? ''})';
        eventIcon = event.detail == 'Yellow Card' ? Icons.warning : Icons.warning_amber;
        iconColor = event.detail == 'Yellow Card' ? Colors.yellow : Colors.red;
        break;
      case 'Var':
        eventDescription = 'VAR: ${event.detail} - ${event.player.name}';
        eventIcon = Icons.videocam;
        iconColor = Colors.purple;
        break;
      default:
        eventDescription = '${event.type}: ${event.player.name}';
        eventIcon = Icons.info;
        iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: event.team.name == match!.homeTeam
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (event.team.name == match!.homeTeam) ...[
            Icon(eventIcon, color: iconColor, size: 20),
            SizedBox(width: 10),
            Text(_formatEventTime(event), style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                eventDescription,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                eventDescription,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis, // Cắt ngắn nếu quá dài
              ),
            ),
            SizedBox(width: 10),
            Text(_formatEventTime(event), style: TextStyle(color: Colors.white)),
            SizedBox(width: 10),
            Icon(eventIcon, color: iconColor, size: 20),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<MatchDetail>(
        future: MatchService().fetchMatchDetail(widget.matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
          }

          match = snapshot.data!;

          // Lấy giá trị thống kê cho home và away team
          final homeBallPossession = _getStatisticValue('Ball Possession', match!.homeTeam, match!.statistics).toString().replaceAll('%', '');
          final awayBallPossession = _getStatisticValue('Ball Possession', match!.awayTeam, match!.statistics).toString().replaceAll('%', '');
          final int homeTotalShots = (_getStatisticValue('Total Shots', match!.homeTeam, match!.statistics) as num).toInt();
          final int awayTotalShots = (_getStatisticValue('Total Shots', match!.awayTeam, match!.statistics) as num).toInt();
          final int homeShotsOnTarget = (_getStatisticValue('Shots on Goal', match!.homeTeam, match!.statistics) as num).toInt();
          final int awayShotsOnTarget = (_getStatisticValue('Shots on Goal', match!.awayTeam, match!.statistics) as num).toInt();
          final int homeShotsOffTarget = (_getStatisticValue('Shots off Goal', match!.homeTeam, match!.statistics) as num).toInt();
          final int awayShotsOffTarget = (_getStatisticValue('Shots off Goal', match!.awayTeam, match!.statistics) as num).toInt();

          return Container(
            color: Colors.black,
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(match!.homeLogo, width: 40, height: 40),
                          SizedBox(width: 10),
                          Text('${match!.homeTeam}', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(width: 20),
                          Text('${match!.goals.home} - ${match!.goals.away}', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 20),
                          Text('${match!.awayTeam}', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(width: 10),
                          Image.network(match!.awayLogo, width: 40, height: 40),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('HT ${match!.goals.home}-${match!.goals.away}', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text(_getGoalScorer(match!.events), style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('Giải bóng đá Serie A Italia', style: TextStyle(fontSize: 12, color: Colors.white)),
                      Text('lúc 01:45 Chủ Nhật, ngày 4 tháng 5, 2025', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: 'Trận đấu'),
                    Tab(text: 'Thống kê'),
                    Tab(text: 'Đội hình'),
                    Tab(text: 'H2H'),
                  ],
                ),
                // Tab Bar View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab "Trận đấu"
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ...match!.events.map((event) => _buildEventRow(event)).toList(),
                            ],
                          ),
                        ),
                      ),
                      // Tab "Thống kê"
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tỷ lệ sở hữu bóng', style: TextStyle(fontSize: 16, color: Colors.white)),
                                  Row(
                                    children: [
                                      Text('$awayBallPossession', style: TextStyle(fontSize: 16, color: Colors.orange)),
                                      SizedBox(width: 10),
                                      Text('$homeBallPossession', style: TextStyle(fontSize: 16, color: Colors.blue)),
                                    ],
                                  ),
                                ],
                              ),
                              LinearProgressIndicator(
                                value: int.parse(homeBallPossession) / 100,
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                minHeight: 10,
                              ),
                              SizedBox(height: 20),
                              _buildStatRow('Tổng số cú sút', homeTotalShots, awayTotalShots),
                              _buildStatRow('Sút trúng khung thành', homeShotsOnTarget, awayShotsOnTarget, isOnTarget: true),
                              _buildStatRow('Sút trượt khung thành', homeShotsOffTarget, awayShotsOffTarget),
                            ],
                          ),
                        ),
                      ),
                      // Placeholder for "Đội hình"
                      Container(
                        color: Colors.black,
                        child: Center(child: Text('Tab Đội hình', style: TextStyle(color: Colors.white))),
                      ),
                      // Placeholder for "H2H"
                      Container(
                        color: Colors.black,
                        child: Center(child: Text('Tab H2H', style: TextStyle(color: Colors.white))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, int homeValue, int awayValue, {bool isOnTarget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
          Row(
            children: [
              Text('$awayValue', style: TextStyle(fontSize: 16, color: isOnTarget ? Colors.orange : Colors.white)),
              SizedBox(width: 10),
              Text('$homeValue', style: TextStyle(fontSize: 16, color: isOnTarget ? Colors.blue : Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
