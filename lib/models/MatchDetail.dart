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
  final List<Lineup> lineups;

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
    required this.lineups,
  });

  factory MatchDetail.fromJson(Map<String, dynamic> json) {
    print('Parsing MatchDetail JSON: $json'); // Log JSON for debugging

    // Helper function to convert Map to List if needed
    List<dynamic> convertToList(dynamic input, String fieldName) {
      if (input == null) return [];
      if (input is List) return input;
      if (input is Map<String, dynamic>) {
        print('Warning: $fieldName is a Map, converting to List: $input');
        return input.values.toList();
      }
      throw FormatException('Invalid $fieldName format: Expected List or Map, got ${input.runtimeType}');
    }

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
      statistics: convertToList(json['statistics'], 'statistics')
          .map((item) => Statistics.fromJson(item as Map<String, dynamic>))
          .toList(),
      events: convertToList(json['events'], 'events')
          .map((item) => Event.fromJson(item as Map<String, dynamic>))
          .toList(),
      lineups: convertToList(json['lineups'], 'lineups')
          .map((item) => Lineup.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

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
      'lineups': lineups.map((lineup) => lineup.toJson()).toList(),
    };
  }
}

class Goals {
  final int home;
  final int away;

  Goals({required this.home, required this.away});

  factory Goals.fromJson(Map<String, dynamic> json) =>
      Goals(home: json['home'] ?? 0, away: json['away'] ?? 0);

  Map<String, dynamic> toJson() => {'home': home, 'away': away};
}

class Statistics {
  final Team team;
  final List<StatisticDetail> statistics;

  Statistics({required this.team, required this.statistics});

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    team: Team.fromJson(json['team'] ?? {'id': 0, 'name': '', 'logo': ''}),
    statistics: (json['statistics'] as List?)
        ?.map((item) => StatisticDetail.fromJson(item as Map<String, dynamic>))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'team': team.toJson(),
    'statistics': statistics.map((s) => s.toJson()).toList(),
  };
}

class StatisticDetail {
  final String type;
  final dynamic value;

  StatisticDetail({required this.type, required this.value});

  factory StatisticDetail.fromJson(Map<String, dynamic> json) => StatisticDetail(
    type: json['type'] ?? '',
    value: json['value'],
  );

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class Team {
  final int id;
  final String name;
  final String logo;

  Team({required this.id, required this.name, required this.logo});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    logo: json['logo'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
  };
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

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    time: Time.fromJson(json['time'] ?? {'elapsed': 0}),
    team: Team.fromJson(json['team'] ?? {'id': 0, 'name': '', 'logo': ''}),
    player: Player.fromJson(json['player'] ?? {'id': 0, 'name': ''}),
    assist: json['assist'] != null ? Assist.fromJson(json['assist'] as Map<String, dynamic>) : null,
    type: json['type'] ?? '',
    detail: json['detail'] ?? '',
    comments: json['comments'],
  );

  Map<String, dynamic> toJson() => {
    'time': time.toJson(),
    'team': team.toJson(),
    'player': player.toJson(),
    'assist': assist?.toJson(),
    'type': type,
    'detail': detail,
    'comments': comments,
  };
}

class Time {
  final int elapsed;
  final int? extra;

  Time({required this.elapsed, this.extra});

  factory Time.fromJson(Map<String, dynamic> json) => Time(
    elapsed: json['elapsed'] ?? 0,
    extra: json['extra'],
  );

  Map<String, dynamic> toJson() => {'elapsed': elapsed, 'extra': extra};
}

class Player {
  final int id;
  final String name;

  Player({required this.id, required this.name});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Assist {
  final int id;
  final String name;

  Assist({required this.id, required this.name});

  factory Assist.fromJson(Map<String, dynamic> json) => Assist(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Lineup {
  final Team team;
  final Coach coach;
  final String formation;
  final List<Player> startXI;
  final List<Player> substitutes;

  Lineup({
    required this.team,
    required this.coach,
    required this.formation,
    required this.startXI,
    required this.substitutes,
  });

  factory Lineup.fromJson(Map<String, dynamic> json) => Lineup(
    team: Team.fromJson(json['team'] ?? {'id': 0, 'name': '', 'logo': ''}),
    coach: Coach.fromJson(json['coach'] ?? {'id': 0, 'name': '', 'photo': ''}),
    formation: json['formation'] ?? '',
    startXI: (json['startXI'] as List?)
        ?.map((item) => Player.fromJson(item as Map<String, dynamic>))
        .toList() ??
        [],
    substitutes: (json['substitutes'] as List?)
        ?.map((item) => Player.fromJson(item as Map<String, dynamic>))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'team': team.toJson(),
    'coach': coach.toJson(),
    'formation': formation,
    'startXI': startXI.map((p) => p.toJson()).toList(),
    'substitutes': substitutes.map((p) => p.toJson()).toList(),
  };
}

class Coach {
  final int id;
  final String name;
  final String photo;

  Coach({required this.id, required this.name, required this.photo});

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    photo: json['photo'] ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'photo': photo};
}