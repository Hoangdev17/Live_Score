class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String utcDate;
  final String competition;
  final String country;
   String score; // computed from goals
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeTeamScore;
  final int awayTeamScore;
  final String status;
  final String venue;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.utcDate,
    required this.competition,
    required this.country,
    required this.score,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.status,
    required this.venue,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final goals = json['goals'] as Map<String, dynamic>? ?? {'home': 0, 'away': 0};
    final homeScore = goals['home'] ?? 0;
    final awayScore = goals['away'] ?? 0;

    return Match(
      id: json['id'] ?? 0,
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      utcDate: json['date'] ?? '',
      competition: json['competition'] ?? '',
      country: json['country'] ?? '',
      score: '$homeScore - $awayScore',
      homeTeamLogo: json['homeLogo'] ?? '',
      awayTeamLogo: json['awayLogo'] ?? '',
      homeTeamScore: homeScore,
      awayTeamScore: awayScore,
      status: json['status'] ?? 'SCHEDULED',
      venue: json['venue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': utcDate,
      'status': status,
      'venue': venue,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeTeamLogo,
      'awayLogo': awayTeamLogo,
      'competition': competition,
      'country': country,
      'goals': {
        'home': homeTeamScore,
        'away': awayTeamScore,
      },
    };
  }
}
