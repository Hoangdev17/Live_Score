class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String utcDate;
  final String competition;
  final String country;
  String score; // This can be updated, so it's not final
  String homeTeamLogo; // This can be updated
  String awayTeamLogo; // This can be updated
  int? homeTeamScore; // Made nullable to handle cases where score might not be immediately available
  int? awayTeamScore; // Made nullable
  String status; // This can be updated
  final String venue;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.utcDate,
    required this.competition,
    required this.country,
    this.score = '', // Provide default for mutable fields
    this.homeTeamLogo = '', // Provide default
    this.awayTeamLogo = '', // Provide default
    this.homeTeamScore, // No required as it's nullable
    this.awayTeamScore, // No required as it's nullable
    this.status = 'SCHEDULED', // Provide default
    this.venue = '', // Provide default
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    // Attempt to safely access nested map values for goals
    final goalsJson = json['goals'] as Map<String, dynamic>?;
    final homeScore = goalsJson != null ? (goalsJson['home'] as int?) : null;
    final awayScore = goalsJson != null ? (goalsJson['away'] as int?) : null;

    return Match(
      id: json['id'] ?? 0,
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      utcDate: json['date'] ?? '',
      competition: json['competition'] ?? '',
      country: json['country'] ?? '',
      // Initialize score based on available data, or empty string
      score: (homeScore != null && awayScore != null) ? '$homeScore - $awayScore' : '',
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

  // Add the copyWith method
  Match copyWith({
    int? id,
    String? homeTeam,
    String? awayTeam,
    String? utcDate,
    String? competition,
    String? country,
    String? score,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeTeamScore,
    int? awayTeamScore,
    String? status,
    String? venue,
  }) {
    return Match(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      utcDate: utcDate ?? this.utcDate,
      competition: competition ?? this.competition,
      country: country ?? this.country,
      score: score ?? this.score,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      homeTeamScore: homeTeamScore ?? this.homeTeamScore,
      awayTeamScore: awayTeamScore ?? this.awayTeamScore,
      status: status ?? this.status,
      venue: venue ?? this.venue,
    );
  }
}