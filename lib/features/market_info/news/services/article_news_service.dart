

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ArticleNewsService {
  static const String _baseUrl = 'https://newsapi.org/v2/everything';


  final List<String> _keywords = [
    'agriculture',
    'farming',
    'crops',
    'farm technology',
    'agritech',
    'crop yield',
    'soil health',
    'irrigation',
    'pesticide',
    'fertilizer',
    'livestock management',
    '"farm equipment"',
  ];


  final List<String> _allowedWords = [
    'agriculture',
    'farming',
    'crop',
    'farm',
    'agritech',
    'soil',
    'irrigation',
    'livestock',
    'fertilizer',
    'pesticide',
    'harvest',
    'agricultural',
    'farmers',
  ];


  Future<List<NewsArticle>> fetchLatestAgriNews() async {
    final apiKey = dotenv.env['NEWS_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("NEWS_API_KEY from NewsAPI.org is missing from .env file.");
      throw Exception("News API Key is not configured.");
    }

    final String coreKeywords = '(${_keywords.join(' OR ')})';


    const String exclusionTerms =
        'NOT "share price" NOT "stock" NOT "commodity" NOT "futures trading" NOT "investment"';

    final String finalQuery = '$coreKeywords $exclusionTerms';

    final url =
        '$_baseUrl?q=${Uri.encodeComponent(finalQuery)}&searchIn=title,description&language=en&sortBy=publishedAt&pageSize=30&page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        final results = decodedJson['articles'];

        if (results is List) {
          final articles = results
              .map((json) => NewsArticle.fromJson(json))
              .where((article) =>
                  article.title != "[Removed]" &&
                  article.imageUrl.isNotEmpty &&
                  _isRelevantArticle(article))
              .toList();

          return articles;
        } else {
          return [];
        }
      } else {
        debugPrint("NewsAPI.org Error Response: ${response.body}");
        throw Exception(
            'Failed to load articles. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching articles: $e");
      throw Exception('Failed to connect to the article service.');
    }
  }


  bool _isRelevantArticle(NewsArticle article) {
    final text = '${article.title} ${article.description}'.toLowerCase();
    return _allowedWords.any((word) => text.contains(word.toLowerCase()));
  }
}

class NewsArticle {
  final String title;
  final String description;
  final String articleUrl;
  final String imageUrl;
  final String sourceName;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.articleUrl,
    required this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available.',
      articleUrl: json['url'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}