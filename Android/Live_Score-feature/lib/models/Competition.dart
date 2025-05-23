class Competition {
  final int id;
  final String name;
  final String country;
  final String flag;
  final String logo;
  final int year;
  final String start;
  final String end;

  Competition({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
    required this.logo,
    required this.year,
    required this.start,
    required this.end,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      flag: json['flag'] ?? '',
      logo: json['logo'] ?? '',
      year: json['season']['year'],
      start: json['season']['start'],
      end: json['season']['end'],
    );
  }
}
