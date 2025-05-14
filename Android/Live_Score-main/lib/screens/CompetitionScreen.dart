import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';  // Để format ngày tháng
import '../models/Competition.dart';
import '../models/Match.dart';
import '../services/CompetitionService.dart';
import 'CompetitionMatchesScreen.dart';  // Import the new screen

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  bool isLoading = true;
  List<Competition> competitions = [];
  bool isMatchesLoading = false;

  @override
  void initState() {
    super.initState();
    _configureImageCache();
    _loadCompetitions();
  }

  void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 10 * 1024 * 1024;
  }

  Future<void> _loadCompetitions() async {
    try {
      final data = await CompetitionService().fetchCompetitions();
      setState(() {
        competitions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading competitions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Competitions')),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView.builder(
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          final comp = competitions[index];
          return GestureDetector(
            onTap: () {
              // Navigate to CompetitionMatchesScreen when a competition is tapped
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
