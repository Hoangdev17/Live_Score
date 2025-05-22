class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String utcDate;
  final String competition;
  final String country;
  final String status;
  final String venue;
  String score;
  String homeTeamLogo;
  String awayTeamLogo;
  int? homeTeamScore;
  int? awayTeamScore;

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
    this.homeTeamScore,
    this.awayTeamScore,
    required this.status,
    required this.venue,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    // Log JSON thô để kiểm tra cấu trúc
    print('Raw JSON for Match ID ${json['id']}: $json');

    // Parse score fields directly from flat structure
    final String score = json['score']?.toString() ?? '';
    final int? homeScore = json['homeTeamScore'] != null ? int.tryParse(json['homeTeamScore'].toString()) : null;
    final int? awayScore = json['awayTeamScore'] != null ? int.tryParse(json['awayTeamScore'].toString()) : null;

    // Debug log để kiểm tra dữ liệu đã parse
    print('Parsed Match ID: ${json['id']}, Status: ${json['status']}, Score: $score, Home Score: $homeScore, Away Score: $awayScore');

    return Match(
      id: json['id'] ?? 0,
      homeTeam: json['homeTeam']?.toString() ?? '',
      awayTeam: json['awayTeam']?.toString() ?? '',
      utcDate: json['date']?.toString() ?? '',
      competition: json['competition']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      score: score,
      homeTeamLogo: json['homeTeamLogo']?.toString() ?? '',
      awayTeamLogo: json['awayTeamLogo']?.toString() ?? '',
      homeTeamScore: homeScore,
      awayTeamScore: awayScore,
      status: json['status']?.toString() ?? 'scheduled',
      venue: json['venue']?.toString() ?? '',
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
      'score': score,
      'homeTeamScore': homeTeamScore,
      'awayTeamScore': awayTeamScore,
    };
  }

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

