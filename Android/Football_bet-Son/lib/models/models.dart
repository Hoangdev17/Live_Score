class Match {
  final int id;
  final String date;
  final String time;
  final String status;
  final int homeScore;
  final int awayScore;
  final Team homeTeam;
  final Team awayTeam;

  Match({
    required this.id,
    required this.date,
    required this.time,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    required this.homeTeam,
    required this.awayTeam,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: int.parse(json["match_id"].toString()),
      date: json["match_date"] ?? "",
      time: json["match_time"] ?? "",
      status: json["match_status"] ?? "",
      homeScore: int.tryParse(json["match_home_score"]?.toString() ?? "0") ?? 0,
      awayScore: int.tryParse(json["match_away_score"]?.toString() ?? "0") ?? 0,
      homeTeam: Team(
        id: int.parse(json["match_home_team_id"].toString()),
        name: json["match_home_team_name"] ?? "Unknown",
        logo: json["team_home_badge"] ?? "",
      ),
      awayTeam: Team(
        id: int.parse(json["match_away_team_id"].toString()),
        name: json["match_away_team_name"] ?? "Unknown",
        logo: json["team_away_badge"] ?? "",
      ),
    );
  }
}