class Competition {
  final int id;
  final String name;
  final String country;
  final String logo;
  final String flag;
  final int year;
  final String start;
  final String end;

  Competition({
    required this.id,
    required this.name,
    required this.country,
    required this.logo,
    required this.flag,
    required this.year,
    required this.start,
    required this.end,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    final season = json['season'] ?? {};
    return Competition(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      logo: json['logo'],
      flag: json['flag'] ?? '',
      year: season['year'] ?? 0,
      start: season['start'] ?? '',
      end: season['end'] ?? '',
    );
  }
}
