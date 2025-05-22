// lib/services/MatchDetailCacheManager.dart

import '../models/MatchDetail.dart';
import '../services/MatchService.dart';

class MatchDetailCacheManager {
  static final MatchDetailCacheManager _instance = MatchDetailCacheManager._internal();

  factory MatchDetailCacheManager() => _instance;

  MatchDetailCacheManager._internal();

  final Map<int, MatchDetail> _cache = {};

  MatchDetail? getFromCache(int matchId) => _cache[matchId];

  Future<MatchDetail> getMatchDetail(int matchId) async {
    if (_cache.containsKey(matchId)) {
      return _cache[matchId]!;
    } else {
      final detail = await MatchService().fetchMatchDetail(matchId);
      _cache[matchId] = detail;
      return detail;
    }
  }

  void clearCache() => _cache.clear();

  void remove(int matchId) => _cache.remove(matchId);

  bool contains(int matchId) => _cache.containsKey(matchId);

  Map<int, MatchDetail> get allCached => Map.unmodifiable(_cache);
}
