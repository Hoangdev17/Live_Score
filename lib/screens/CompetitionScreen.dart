import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/Competition.dart';
import '../services/CompetitionService.dart';
import 'CompetitionMatchesScreen.dart';
import '../services/CompetitionCacheManager.dart';

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  bool isLoading = true;
  bool hasMoreData = true;
  int currentPage = 1;
  List<Competition> competitions = [];
  final ScrollController _scrollController = ScrollController();
  final cacheManager = CompetitionCacheManager();

  @override
  void initState() {
    super.initState();
    _configureImageCache();
    _loadCompetitions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMoreData) {
        _loadMoreCompetitions();
      }
    }
  }

  void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 10 * 1024 * 1024;
  }

  Future<void> _loadCompetitions() async {
    try {
      setState(() => isLoading = true);
      final data = await CompetitionService().fetchCompetitions(page: currentPage);
      cacheManager.cacheCompetitions(data);

      setState(() {
        competitions = data;
        isLoading = false;
        hasMoreData = data.isNotEmpty;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading competitions: $e')),
      );
    }
  }

  Future<void> _loadMoreCompetitions() async {
    setState(() => isLoading = true);
    try {
      final nextPage = currentPage + 1;
      final data = await CompetitionService().fetchCompetitions(page: nextPage);
      cacheManager.cacheCompetitions(data);

      if (data.isEmpty) {
        hasMoreData = false;
      } else {
        setState(() {
          currentPage = nextPage;
          competitions.addAll(data);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thêm dữ liệu: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Competitions'),
        backgroundColor: Color(0xFF1A2A3A),
      ),
      backgroundColor: Color(0xFF1A2A3A),
      body: isLoading && competitions.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView.builder(
        controller: _scrollController,
        itemCount: competitions.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == competitions.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            );
          }
          final comp = competitions[index];
          return _buildCompetitionTile(comp);
        },
      ),
    );
  }

  Widget _buildCompetitionTile(Competition comp) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompetitionMatchesScreen(
              leagueId: comp.id,
              season: comp.year,
              leagueName: comp.name,
              logo: comp.logo,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildLogo(comp.logo, comp.flag),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comp.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('${comp.country} • ${comp.year}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  Text('${comp.start} - ${comp.end}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String logoUrl, String flagUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        width: 40,
        color: Colors.grey[800],
        child: logoUrl.isNotEmpty && Uri.parse(logoUrl).isAbsolute
            ? CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.contain,
          memCacheHeight: 80,
          memCacheWidth: 80,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.blueAccent),
          ),
          errorWidget: (context, url, error) => _buildFallbackWidget(flagUrl),
        )
            : _buildFallbackWidget(flagUrl),
      ),
    );
  }

  Widget _buildFallbackWidget(String flagUrl) {
    return flagUrl.isNotEmpty && Uri.parse(flagUrl).isAbsolute
        ? CachedNetworkImage(
      imageUrl: flagUrl,
      height: 40,
      width: 40,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.redAccent),
    )
        : Icon(Icons.emoji_events, color: Colors.blueAccent);
  }
}