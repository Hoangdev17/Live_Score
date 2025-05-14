
import 'package:flutter/material.dart';
import '../models/MatchDetail.dart';
import '../services/MatchService.dart';
<<<<<<< HEAD

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
print('Rendering lineup for team: ${lineup.teamName}'); // Log lineup
// Xác định logo dựa trên teamName so sánh với homeTeam hoặc awayTeam
final isHomeTeam = lineup.teamName == match!.homeTeam;
final teamLogo = isHomeTeam ? match!.homeLogo : match!.awayLogo;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
color: Colors.green,
padding: EdgeInsets.all(8.0),
child: Row(
children: [
Image.network(
teamLogo.isNotEmpty ? teamLogo : 'https://via.placeholder.com/30',
width: 30,
height: 30,
errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white),
),
SizedBox(width: 10),
Text(
lineup.teamName.isNotEmpty ? lineup.teamName : 'Unknown Team',
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
=======
import '../utils/utils.dart';
import '../models/Match.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  MatchDetailScreen({required this.matchId}) {
    print('Navigating to MatchDetailScreen with matchId: $matchId');
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
    print('Rendering lineup: name=${lineup.team.name}, id=${lineup.team.id}, index=${match!.lineups.indexOf(lineup)}, logo=${lineup.team.logo}');

    String teamName = lineup.team.name.isNotEmpty ? lineup.team.name : '';
    bool isHomeTeam = false;
    if (lineup.team.name.isNotEmpty) {
      isHomeTeam = lineup.team.name.toLowerCase() == match!.homeTeam.toLowerCase();
    } else {
      int lineupIndex = match!.lineups.indexOf(lineup);
      isHomeTeam = lineupIndex == 0;
      print('Using index-based fallback: isHomeTeam=$isHomeTeam, index=$lineupIndex');
    }

    if (teamName.isEmpty) {
      teamName = isHomeTeam ? match!.homeTeam : match!.awayTeam;
      print('Using fallback teamName: teamName=$teamName, isHomeTeam=$isHomeTeam');
    }

    teamName = teamName.isNotEmpty ? teamName : 'Unknown Team';
    String teamLogo = lineup.team.logo.isNotEmpty ? lineup.team.logo : '';
    if (teamLogo.isEmpty) {
      teamLogo = isHomeTeam ? match!.homeLogo : match!.awayLogo;
      print('Using fallback teamLogo: teamLogo=$teamLogo, isHomeTeam=$isHomeTeam');
    }
    teamLogo = teamLogo.isNotEmpty ? teamLogo : 'https://via.placeholder.com/30';
    print('Final teamName: $teamName, teamLogo: $teamLogo');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.green,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.network(
                teamLogo,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                teamName,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Huấn luyện viên: ${lineup.coach.name.isNotEmpty ? lineup.coach.name : 'N/A'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Sơ đồ: ${lineup.formation.isNotEmpty ? lineup.formation : 'N/A'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Đội hình xuất phát:',
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (lineup.startXI.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          )),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Dự bị:',
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        if (lineup.substitutes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          )),
      ],
    );
  }

  Widget _buildH2HSection(List<Match> h2hMatches) {
    if (h2hMatches.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu lịch sử đối đầu',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      );
    }

    // Calculate summary statistics
    int homeWins = 0;
    int awayWins = 0;
    int draws = 0;
    for (var h2hMatch in h2hMatches) {
      if (h2hMatch.homeTeamScore > h2hMatch.awayTeamScore) {
        homeWins++;
      } else if (h2hMatch.awayTeamScore > h2hMatch.homeTeamScore) {
        awayWins++;
      } else {
        draws++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tóm tắt đối đầu',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            match?.homeTeam ?? 'Unknown Team',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$homeWins thắng',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$draws hòa',
                            style: TextStyle(fontSize: 16, color: Colors.yellow),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            match?.awayTeam ?? 'Unknown Team',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$awayWins thắng',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Match List
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: h2hMatches.length,
            itemBuilder: (context, index) {
              final h2hMatch = h2hMatches[index];
              String result = 'Hòa';
              Color resultColor = Colors.yellow;
              if (h2hMatch.homeTeamScore > h2hMatch.awayTeamScore) {
                result = h2hMatch.homeTeam.isNotEmpty ? h2hMatch.homeTeam : 'Home Team';
                resultColor = Colors.green;
              } else if (h2hMatch.awayTeamScore > h2hMatch.homeTeamScore) {
                result = h2hMatch.awayTeam.isNotEmpty ? h2hMatch.awayTeam : 'Away Team';
                resultColor = Colors.green;
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            h2hMatch.competition.isNotEmpty ? h2hMatch.competition : 'Unknown Competition',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          h2hMatch.utcDate.isNotEmpty ? formatUtcDate(h2hMatch.utcDate) ?? 'N/A' : 'N/A',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.network(
                                h2hMatch.homeTeamLogo.isNotEmpty ? h2hMatch.homeTeamLogo : 'https://via.placeholder.com/30',
                                width: 30,
                                height: 30,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white, size: 30),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  h2hMatch.homeTeam.isNotEmpty ? h2hMatch.homeTeam : 'Unknown Team',
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${h2hMatch.homeTeamScore} - ${h2hMatch.awayTeamScore}',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  h2hMatch.awayTeam.isNotEmpty ? h2hMatch.awayTeam : 'Unknown Team',
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Image.network(
                                h2hMatch.awayTeamLogo.isNotEmpty ? h2hMatch.awayTeamLogo : 'https://via.placeholder.com/30',
                                width: 30,
                                height: 30,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: Colors.white, size: 30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Kết quả: ',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          result,
                          style: TextStyle(
                            fontSize: 14,
                            color: resultColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
            print('FutureBuilder error: ${snapshot.error}');
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
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No data available for this match',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          }

          match = snapshot.data!;
          print('Match data loaded: ${match!.homeTeam} vs ${match!.awayTeam}');

          if (match!.homeTeam.isEmpty || match!.awayTeam.isEmpty) {
            return Center(
              child: Text(
                'Invalid match data: Missing team information',
                style: TextStyle(fontSize: 16, color: Colors.white),
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

          final homeTeamId = match!.lineups.isNotEmpty ? match!.lineups[0].team.id : 0;
          final awayTeamId = match!.lineups.length > 1 ? match!.lineups[1].team.id : 0;

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
                      FutureBuilder<List<Match>>(
                        future: MatchService().fetchH2H(homeTeamId, awayTeamId),
                        builder: (context, h2hSnapshot) {
                          if (h2hSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                          } else if (h2hSnapshot.hasError) {
                            print('H2H FutureBuilder error: ${h2hSnapshot.error}');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Không thể tải dữ liệu lịch sử đối đầu. Vui lòng thử lại.',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => setState(() {}),
                                    child: Text('Thử lại'),
                                  ),
                                ],
                              ),
                            );
                          } else if (!h2hSnapshot.hasData || h2hSnapshot.data!.isEmpty) {
                            return Center(
                              child: Text(
                                'Không có dữ liệu lịch sử đối đầu',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            );
                          }

                          return _buildH2HSection(h2hSnapshot.data!);
                        },
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
    final total = homeValue + awayValue;
    final progress = total > 0 ? homeValue / total : 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$homeValue', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              Text('$awayValue', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(
                  isOnTarget ? Colors.redAccent : Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
>>>>>>> e39c324 (Update scroll load)
}
