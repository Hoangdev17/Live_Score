class MatchDetail {
  final int id;
  final String date;
  final String status;
  final String venue;
  final String referee;
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final Goals goals;
  final String league;
  final int season;
  final List<Statistics> statistics;
  final List<Event> events;

  MatchDetail({
    required this.id,
    required this.date,
    required this.status,
    required this.venue,
    required this.referee,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    required this.goals,
    required this.league,
    required this.season,
    required this.statistics,
    required this.events,
  });

  // Factory constructor to parse JSON data
  factory MatchDetail.fromJson(Map<String, dynamic> json) {
    return MatchDetail(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      venue: json['venue'] ?? '',
      referee: json['referee'] ?? '',
      homeTeam: json['homeTeam'] ?? '',
      awayTeam: json['awayTeam'] ?? '',
      homeLogo: json['homeLogo'] ?? '',
      awayLogo: json['awayLogo'] ?? '',
      goals: Goals.fromJson(json['goals'] ?? {'home': 0, 'away': 0}),
      league: json['league'] ?? '',
      season: json['season'] ?? 0,
      statistics: (json['statistics'] as List?)
          ?.map((item) => Statistics.fromJson(item))
          .toList() ?? [],
      events: (json['events'] as List?)
          ?.map((item) => Event.fromJson(item))
          .toList() ?? [],
    );
  }

  // toJson method to convert MatchDetail object back into JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'venue': venue,
      'referee': referee,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeLogo': homeLogo,
      'awayLogo': awayLogo,
      'goals': goals.toJson(),
      'league': league,
      'season': season,
      'statistics': statistics.map((stat) => stat.toJson()).toList(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }
}

class Goals {
  final int home;
  final int away;

  Goals({
    required this.home,
    required this.away,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      home: json['home'] ?? 0,
      away: json['away'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home,
      'away': away,
    };
  }
}

class Statistics {
  final Team team;
  final List<StatisticDetail> statistics;

  Statistics({
    required this.team,
    required this.statistics,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      team: Team.fromJson(json['team'] ?? {'id': 0, 'name': '', 'logo': ''}),
      statistics: (json['statistics'] as List?)
          ?.map((item) => StatisticDetail.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team': team.toJson(),
      'statistics': statistics.map((stat) => stat.toJson()).toList(),
    };
  }
}

class Team {
  final int id;
  final String name;
  final String logo;

  Team({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class StatisticDetail {
  final String type;
  final dynamic value; // Hỗ trợ cả số và chuỗi (ví dụ: "34%")

  StatisticDetail({
    required this.type,
    required this.value,
  });

  factory StatisticDetail.fromJson(Map<String, dynamic> json) {
    return StatisticDetail(
      type: json['type'] ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
}

class Event {
  final Time time;
  final Team team;
  final Player player;
  final Assist? assist;
  final String type;
  final String detail;
  final String? comments;

  Event({
    required this.time,
    required this.team,
    required this.player,
    this.assist,
    required this.type,
    required this.detail,
    this.comments,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      time: Time.fromJson(json['time'] ?? {'elapsed': 0}),
      team: Team.fromJson(json['team'] ?? {'id': 0, 'name': '', 'logo': ''}),
      player: Player.fromJson(json['player'] ?? {'id': 0, 'name': ''}),
      assist: json['assist'] != null ? Assist.fromJson(json['assist']) : null,
      type: json['type'] ?? '',
      detail: json['detail'] ?? '',
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toJson(),
      'team': team.toJson(),
      'player': player.toJson(),
      'assist': assist?.toJson(),
      'type': type,
      'detail': detail,
      'comments': comments,
    };
  }
}

class Time {
  final int elapsed;
  final int? extra;

  Time({
    required this.elapsed,
    this.extra,
  });

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      elapsed: json['elapsed'] ?? 0,
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elapsed': elapsed,
      'extra': extra,
    };
  }
}

class Player {
  final int id;
  final String name;

  Player({
    required this.id,
    required this.name,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Assist {
  final int id;
  final String name;

  Assist({
    required this.id,
    required this.name,
  });

  factory Assist.fromJson(Map<String, dynamic> json) {
    return Assist(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}