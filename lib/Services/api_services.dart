import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:watchpool/Models/channel_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:watchpool/Models/video_model.dart';

class APIService {
  APIService._instantiate();

  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<Channel> fetchChannel({String? channelId}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'id': channelId!,
      'key': dotenv.env['YOUTUBE_API'] ?? '',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);

      // Fetch first batch of videos from uploads playlist
      channel.videos = await fetchVideosFromPlaylist(
        playlistId: channel.uploadPlaylistId,
      );
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<List<Video>> fetchVideosFromPlaylist({String? playlistId}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playlistId!,
      'maxResults': '8',
      'pageToken': _nextPageToken,
      'key': dotenv.env['YOUTUBE_API'] ?? '',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      _nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];

      List<Video> videos = [];
      for (var json in videosJson) {
        String videoId = json['snippet']['resourceId']['videoId'];
        Map<String, dynamic> videoStats = await fetchVideoStatistics(videoId);
        Map<String, dynamic> channelDetails =
            await fetchChannelDetails(json['snippet']['channelId']);

        json['snippet']['channelProfilePictureUrl'] =
            channelDetails['profilePictureUrl'];
        videos.add(Video.fromMap(json['snippet'], videoStats));
      }
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<Map<String, dynamic>> fetchVideoStatistics(String videoId) async {
  Map<String, String> parameters = {
    'part': 'statistics',
    'id': videoId,
    'key': dotenv.env['YOUTUBE_API'] ?? '',
  };
  Uri uri = Uri.https(_baseUrl, '/youtube/v3/videos', parameters);
  var response = await http.get(uri);
  if (response.statusCode == 200) {
    return json.decode(response.body)['items'][0]['statistics'];
  } else {
    throw json.decode(response.body)['error']['message'];
  }
}

Future<Map<String, dynamic>> fetchChannelDetails(String channelId) async {
  Map<String, String> parameters = {
    'part': 'snippet',
    'id': channelId,
    'key': dotenv.env['YOUTUBE_API'] ?? '',
  };
  Uri uri = Uri.https(_baseUrl, '/youtube/v3/channels', parameters);
  var response = await http.get(uri);
  if (response.statusCode == 200) {
    var data = json.decode(response.body)['items'][0]['snippet'];
    return {
      'profilePictureUrl': data['thumbnails']['default']['url'],
    };
  } else {
    throw json.decode(response.body)['error']['message'];
  }
}
}
