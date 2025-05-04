class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String utcDate; // Renamed from 'date' to match previous code
  final String competition; // Not present in JSON, but kept for compatibility
  final String country; // Not present in JSON, but kept for compatibility
  String score; // Computed from goals for compatibility
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeTeamScore;
  final int awayTeamScore;
  final String status;
  final String venue; // Added to match the JSON

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

  // Factory constructor to parse JSON data
  factory Match.fromJson(Map<String, dynamic> json) {
    final goals = json['goals'] as Map<String, dynamic>? ?? {'home': 0, 'away': 0};
    final homeScore = goals['home'] as int? ?? 0;
    final awayScore = goals['away'] as int? ?? 0;

    return Match(
      id: json['id'] ?? 0,
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      utcDate: json['date'] ?? '', // Ensure this matches with the API
      competition: json['competition'] ?? '', // Default to empty string if not available
      country: json['country'] ?? '', // Default to empty string if not available
      score: json['score'], // Construct score string from goals
      homeTeamLogo: json['homeTeamLogo'] ?? '',
      awayTeamLogo: json['awayTeamLogo'] ?? '',
      homeTeamScore: json['homeTeamScore'],
      awayTeamScore: json['awayTeamScore'],
      status: json['status'] ?? 'SCHEDULED',
      venue: json['venue'] ?? '',
    );
  }

  // toJson method to convert Match object back into JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': utcDate,  // Here we return the 'utcDate' field as 'date' in JSON
      'status': status,
      'venue': venue,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeTeamLogo,
      'awayLogo': awayTeamLogo,
      'goals': {
        'home': homeTeamScore,
        'away': awayTeamScore,
      },
    };
  }
}
