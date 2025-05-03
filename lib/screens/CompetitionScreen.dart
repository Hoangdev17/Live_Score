import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/Competition.dart';
import '../services/CompetitionService.dart';

class CompetitionScreen extends StatefulWidget {
  @override
  _CompetitionScreenState createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  bool isLoading = true;
  List<Competition> competitions = [];

  @override
  void initState() {
    super.initState();
    // Configure the cache size for images
    _configureImageCache();
    _loadCompetitions();
  }

  // Configure image cache settings
  void _configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100; // Limit the number of images cached
    PaintingBinding.instance.imageCache.maximumSizeBytes = 10 * 1024 * 1024; // 10MB cache size limit
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
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : ListView.builder(
      cacheExtent: 1000.0, // Cache a large part of the list for smooth scrolling
      itemCount: competitions.length,
      itemBuilder: (context, index) {
        final comp = competitions[index];
        return _buildCompetitionTile(comp);
      },
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
                Text(
                  comp.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${comp.country} • ${comp.year}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  '${comp.start} - ${comp.end}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String logoUrl, String flagUrl) {
    // Check if the logo URL is valid
    if (logoUrl.isEmpty || !Uri.parse(logoUrl).isAbsolute) {
      print('Invalid logo URL: $logoUrl');
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
          height: 40,
          width: 40,
          fit: BoxFit.contain,
          memCacheHeight: 80, // Limit cache size to reduce memory usage
          memCacheWidth: 80,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) {
            print('Error loading logo: $error, URL: $logoUrl');
            return _buildFallbackWidget(flagUrl);
          },
        ),
      ),
    );
  }

  Widget _buildFallbackWidget(String flagUrl) {
    // If flag URL is valid, attempt to load the flag
    if (flagUrl.isNotEmpty && Uri.parse(flagUrl).isAbsolute) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 40,
          width: 40,
          color: Colors.grey[700],
          child: CachedNetworkImage(
            imageUrl: flagUrl,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
            memCacheHeight: 80,
            memCacheWidth: 80,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (context, url, error) {
              return Icon(Icons.error, color: Colors.redAccent, size: 24);
            },
          ),
        ),
      );
    }

    // If no valid flag is found, show a placeholder
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.image_not_supported, color: Colors.white, size: 24),
    );
  }
}
