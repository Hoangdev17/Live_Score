import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/Competition.dart';
import '../services/CompetitionService.dart';
import 'CompetitionMatchesScreen.dart';

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool isLoading = true;
  bool isMatchesLoading = false;
  List<Competition> competitions = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _configureImageCache();
    _scrollController.addListener(_onScroll);
    _loadCompetitions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 10 * 1024 * 1024;
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadCompetitions();
    }
  }

  Future<void> _loadCompetitions() async {
    if (!_hasMore || isMatchesLoading) return;

    setState(() => isMatchesLoading = true);

    try {
      final data = await CompetitionService().fetchCompetitions(
        page: _currentPage,
        perPage: 20,
      );

      setState(() {
        _currentPage++;
        competitions.addAll(data);
        _hasMore = data.length >= 20; // Giả sử mỗi page trả về 20 items
        isLoading = false;
        isMatchesLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isMatchesLoading = false;
      });
      print('Lỗi khi tải dữ liệu: $e');
    }
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _hasMore
            ? CircularProgressIndicator(color: Colors.blueAccent)
            : Text('No more competitions', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Competitions')),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView.builder(
        controller: _scrollController,
        itemCount: competitions.length + 1,
        itemBuilder: (context, index) {
          if (index < competitions.length) {
            final comp = competitions[index];
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
              child: _buildCompetitionTile(comp),
            );
          } else {
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildCompetitionTile(Competition comp) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildLogo(String logoUrl, String flagUrl) {
    if (logoUrl.isEmpty || !Uri.parse(logoUrl).isAbsolute) {
      return _buildFallbackWidget(flagUrl);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        width: 40,
        color: Colors.grey[700],
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.contain,
          memCacheHeight: 80,
          memCacheWidth: 80,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
          ),
          errorWidget: (context, url, error) => _buildFallbackWidget(flagUrl),
        ),
      ),
    );
  }

  Widget _buildFallbackWidget(String flagUrl) {
    if (flagUrl.isNotEmpty && Uri.parse(flagUrl).isAbsolute) {
      return CachedNetworkImage(
        imageUrl: flagUrl,
        height: 40,
        width: 40,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.redAccent),
      );
    }
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(8)),
      child: Icon(Icons.image_not_supported, color: Colors.white),
    );
  }
}