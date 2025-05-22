// lib/services/CompetitionCacheManager.dart

import '../models/Competition.dart';
import '../services/CompetitionService.dart';

class CompetitionCacheManager {
  static final CompetitionCacheManager _instance = CompetitionCacheManager._internal();

  factory CompetitionCacheManager() => _instance;

  CompetitionCacheManager._internal();

  final Map<int, Competition> _cache = {};

  Competition? getFromCache(int competitionId) => _cache[competitionId];

  Future<Competition> getCompetition(int competitionId) async {
    if (_cache.containsKey(competitionId)) {
      return _cache[competitionId]!;
    } else {
      final competitions = await CompetitionService().fetchCompetitions();
      final competition = competitions.firstWhere((c) => c.id == competitionId);
      _cache[competitionId] = competition;
      return competition;
    }
  }

  void cacheCompetitions(List<Competition> competitions) {
    for (final competition in competitions) {
      _cache[competition.id] = competition;
    }
  }

  void clearCache() => _cache.clear();

  void remove(int competitionId) => _cache.remove(competitionId);

  bool contains(int competitionId) => _cache.containsKey(competitionId);

  Map<int, Competition> get allCached => Map.unmodifiable(_cache);
}