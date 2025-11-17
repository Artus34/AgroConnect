

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class VideoNewsService {

  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3/search';

  final String _coreQuery = 'agriculture OR farming OR crops OR harvest OR agritech';

  Future<List<YouTubeVideo>> fetchLatestAgriVideos() async {
    final apiKey = dotenv.env['YOUTUBE_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("YOUTUBE_API_KEY is missing from .env file.");
      throw Exception("YouTube API Key is not configured.");
    }


    final Map<String, dynamic> queryParams = {
      'part': 'snippet',      
      'q': _coreQuery,
      'type': 'video',         
      'maxResults': 20,        
      'key': apiKey,
      'order': 'date',         
    };


    final uri = Uri.parse(_baseUrl).replace(
        queryParameters:
            queryParams.map((key, value) => MapEntry(key, value.toString())));

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        final results = decodedJson['items'];

        if (results is List) {
          return results
              .map((json) => YouTubeVideo.fromJson(json))
              
              .where((video) =>
                  video.videoId.isNotEmpty && video.thumbnailUrl.isNotEmpty)
              .toList();
        } else {
          return [];
        }
      } else {
        debugPrint("YouTube API Error Response: ${response.body}");
        throw Exception(
          'Failed to load videos. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching videos: $e");
      throw Exception('Failed to connect to the video service.');
    }
  }
}


class YouTubeVideo {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String videoUrl;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  }) : videoUrl = 'https://www.youtube.com/watch?v=$videoId';

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final id = json['id']['videoId'] ?? '';
    final snippet = json['snippet'];

    return YouTubeVideo(
      videoId: id,
      title: snippet['title'] ?? 'No Title',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? '',
    );
  }
}