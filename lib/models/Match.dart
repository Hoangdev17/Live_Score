class Match {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final String utcDate;
  final String competition;
  final String country;
   String score;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.utcDate,
    required this.competition,
    required this.country,
    required this.score,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      utcDate: json['utcDate'],
      competition: json['competition'],
      country: json['country'],
      score: json['score'],
    );
  }
}
