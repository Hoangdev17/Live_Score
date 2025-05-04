import 'package:flutter/material.dart';
import '../models/MatchDetail.dart';
import '../services/MatchService.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  MatchDetailScreen({required this.matchId}) {
    print('Navigating to MatchDetailScreen with matchId: $matchId'); // Log matchId
  }

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MatchDetail? match;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  String _getGoalScorer(List<Event> events) {
    final goalEvents = events.where((event) => event.type == 'Goal').toList();
    if (goalEvents.isNotEmpty) {
      return '${goalEvents.first.player.name} (${goalEvents.first.time.elapsed}′)';
    }
    return '';
  }

  String _formatEventTime(Event event) {
    final extraTime = event.time.extra != null ? '+${event.time.extra}' : '';
    return '${event.time.elapsed}$extraTime′';
  }

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
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                eventDescription,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
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

  Widget _buildLineupSection(Lineup lineup) {
    print('Rendering lineup for team: ${lineup.team.name}'); // Log lineup
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.green,
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.network(
                lineup.team.logo.isNotEmpty ? lineup.team.logo : 'https://via.placeholder.com/30',
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                lineup.team.name.isNotEmpty ? lineup.team.name : 'Unknown Team',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Huấn luyện viên: ${lineup.coach.name.isNotEmpty ? lineup.coach.name : 'N/A'}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Sơ đồ: ${lineup.formation.isNotEmpty ? lineup.formation : 'N/A'}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Đội hình xuất phát:',
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (lineup.startXI.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Không có thông tin',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          )
        else
          ...lineup.startXI.map((player) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              player.name.isNotEmpty ? player.name : 'Unknown Player',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          )),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Dự bị:',
            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (lineup.substitutes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Không có thông tin',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          )
        else
          ...lineup.substitutes.map((player) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              player.name.isNotEmpty ? player.name : 'Unknown Player',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            print('FutureBuilder error: ${snapshot.error}'); // Log error
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load match details. Please try again.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {}), // Retry fetching
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No data available for this match',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          match = snapshot.data!;
          print('Match data loaded: ${match!.homeTeam} vs ${match!.awayTeam}'); // Log match data

          if (match!.homeTeam.isEmpty || match!.awayTeam.isEmpty) {
            return Center(
              child: Text(
                'Invalid match data: Missing team information',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final homeBallPossession = _getStatisticValue('Ball Possession', match!.homeTeam, match!.statistics).toString().replaceAll('%', '');
          final awayBallPossession = _getStatisticValue('Ball Possession', match!.awayTeam, match!.statistics).toString().replaceAll('%', '');
          final int homeTotalShots = (_getStatisticValue('Total Shots', match!.homeTeam, match!.statistics) as num?)?.toInt() ?? 0;
          final int awayTotalShots = (_getStatisticValue('Total Shots', match!.awayTeam, match!.statistics) as num?)?.toInt() ?? 0;
          final int homeShotsOnTarget = (_getStatisticValue('Shots on Goal', match!.homeTeam, match!.statistics) as num?)?.toInt() ?? 0;
          final int awayShotsOnTarget = (_getStatisticValue('Shots on Goal', match!.awayTeam, match!.statistics) as num?)?.toInt() ?? 0;
          final int homeShotsOffTarget = (_getStatisticValue('Shots off Goal', match!.homeTeam, match!.statistics) as num?)?.toInt() ?? 0;
          final int awayShotsOffTarget = (_getStatisticValue('Shots off Goal', match!.awayTeam, match!.statistics) as num?)?.toInt() ?? 0;

          return Container(
            color: Colors.black,
            child: Column(
              children: [
                Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            match!.homeLogo.isNotEmpty ? match!.homeLogo : 'https://via.placeholder.com/40',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text('${match!.homeTeam}', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(width: 20),
                          Text('${match!.goals.home} - ${match!.goals.away}', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 20),
                          Text('${match!.awayTeam}', style: TextStyle(fontSize: 18, color: Colors.white)),
                          SizedBox(width: 10),
                          Image.network(
                            match!.awayLogo.isNotEmpty ? match!.awayLogo : 'https://via.placeholder.com/40',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('HT ${match!.goals.home}-${match!.goals.away}', style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text(_getGoalScorer(match!.events), style: TextStyle(fontSize: 14, color: Colors.white)),
                      Text('Giải bóng đá ${match!.league}', style: TextStyle(fontSize: 12, color: Colors.white)),
                      Text('lúc ${match!.date}', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ),
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (match!.events.isEmpty)
                                Text(
                                  'Không có sự kiện nào',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                )
                              else
                                ...match!.events.map((event) => _buildEventRow(event)).toList(),
                            ],
                          ),
                        ),
                      ),
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
                                      Text('$awayBallPossession%', style: TextStyle(fontSize: 16, color: Colors.orange)),
                                      SizedBox(width: 10),
                                      Text('$homeBallPossession%', style: TextStyle(fontSize: 16, color: Colors.blue)),
                                    ],
                                  ),
                                ],
                              ),
                              LinearProgressIndicator(
                                value: double.tryParse(homeBallPossession) ?? 0 / 100,
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
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (match!.lineups.isEmpty)
                                Text(
                                  'Không có thông tin đội hình',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                )
                              else
                                ...match!.lineups.map((lineup) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: _buildLineupSection(lineup),
                                )),
                            ],
                          ),
                        ),
                      ),
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