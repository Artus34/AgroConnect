import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/article_news_service.dart';
import '../services/video_news_service.dart';

class NewsProvider with ChangeNotifier {
  
  final ArticleNewsService _articleService = ArticleNewsService();
  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _articles;
  bool _isArticlesLoading = false;
  bool get isArticlesLoading => _isArticlesLoading;
  String? _articleErrorMessage;
  String? get articleErrorMessage => _articleErrorMessage;

  
  final VideoNewsService _videoService = VideoNewsService();
  List<YouTubeVideo> _videos = [];
  List<YouTubeVideo> get videos => _videos;
  bool _isVideosLoading = false;
  bool get isVideosLoading => _isVideosLoading;
  String? _videoErrorMessage;
  String? get videoErrorMessage => _videoErrorMessage;

  
  NewsProvider() {
    fetchArticles();
    fetchVideos();
  }

  

  
  Future<void> fetchArticles({bool force = false}) async {
    if (_articles.isNotEmpty && !force) return;

    _isArticlesLoading = true;
    _articleErrorMessage = null;
    notifyListeners();

    try {
      _articles = await _articleService.fetchLatestAgriNews();
    } catch (e) {
      _articleErrorMessage = e.toString();
      debugPrint("NewsProvider (Articles) Error: $_articleErrorMessage");
    } finally {
      _isArticlesLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> fetchVideos({bool force = false}) async {
    if (_videos.isNotEmpty && !force) return;

    _isVideosLoading = true;
    _videoErrorMessage = null;
    notifyListeners();

    try {
      _videos = await _videoService.fetchLatestAgriVideos();
    } catch (e) {
      _videoErrorMessage = e.toString();
      debugPrint("NewsProvider (Videos) Error: $_videoErrorMessage");
    } finally {
      _isVideosLoading = false;
      notifyListeners();
    }
  }
}