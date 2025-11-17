import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../market_info/news/controllers/news_provider.dart';
import '../../market_info/news/views/news_feed_screen.dart';

class NewsPanel extends StatelessWidget {
  final Function(String) onLaunchUrl;
  const NewsPanel({super.key, required this.onLaunchUrl});

  // Define the very light green color for the card background
  static const Color _lightBrownBackground = Color(0xFFF5F5DC); // A soft, pale green (Honeydew)
  // Define the default black color for text
  static const Color _darkTextColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      // ⭐️ CHANGE: Set card color to very light green
      color: _lightBrownBackground,
      shadowColor: AppColors.primaryGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.primaryGreen,
              // ⭐️ CHANGE: Set active tab label color to black/primary green
              labelColor: _darkTextColor, 
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(child: Text('ARTICLES', style: TextStyle(color: _darkTextColor))),
                Tab(child: Text('VIDEOS', style: TextStyle(color: _darkTextColor))),
              ],
            ),
            SizedBox(
              height: 240,
              child: Consumer<NewsProvider>(
                builder: (context, provider, child) {
                  return TabBarView(
                    children: [
                      _buildArticlePreview(provider),
                      _buildVideoPreview(provider),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsFeedScreen()),
                );
              },
              // Keeping button color primaryGreen for consistency/action, but will ensure its text is visible
              child: const Text('VIEW ALL NEWS', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlePreview(NewsProvider provider) {
    if (provider.isArticlesLoading && provider.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (provider.articleErrorMessage != null) {
      // ⭐️ CHANGE: Set error message text color to black
      return Center(child: Text(provider.articleErrorMessage!, style: const TextStyle(color: _darkTextColor)));
    }
    final articlesToShow = provider.articles.take(7).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: articlesToShow.length,
      itemBuilder: (context, index) {
        final article = articlesToShow[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              article.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image, color: _darkTextColor),
            ),
          ),
          // ⭐️ CHANGE: Set title text color to black
          title: Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, color: _darkTextColor)),
          onTap: () => onLaunchUrl(article.articleUrl),
        );
      },
      separatorBuilder: (_, __) => const Divider(indent: 72),
    );
  }

  Widget _buildVideoPreview(NewsProvider provider) {
    if (provider.isVideosLoading && provider.videos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }
    if (provider.videoErrorMessage != null) {
      // ⭐️ CHANGE: Set error message text color to black
      return Center(child: Text(provider.videoErrorMessage!, style: const TextStyle(color: _darkTextColor)));
    }
    final videosToShow = provider.videos.take(7).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: videosToShow.length,
      itemBuilder: (context, index) {
        final video = videosToShow[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              video.thumbnailUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_outline, color: _darkTextColor),
            ),
          ),
          // ⭐️ CHANGE: Set title text color to black
          title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, color: _darkTextColor)),
          onTap: () => onLaunchUrl(video.videoUrl),
        );
      },
      separatorBuilder: (_, __) => const Divider(indent: 72),
    );
  }
}
