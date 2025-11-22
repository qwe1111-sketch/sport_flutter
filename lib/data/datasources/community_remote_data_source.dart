import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/models/community_post_model.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';

abstract class CommunityRemoteDataSource {
  Future<List<CommunityPostModel>> getPosts();
  Future<List<CommunityPostModel>> getMyPosts(); // New method
  Future<void> createPost(String title, String content, List<String>? imageUrls, List<String>? videoUrls, String? userAvatarUrl);
  Future<void> deletePost(int postId);
  Future<Map<String, dynamic>> favoritePost(int postId);
  Future<Map<String, dynamic>> dislikePost(int postId);
  Future<Map<String, dynamic>> likePost(int postId);
  Future<List<CommunityPostModel>> getFavoritePosts();
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AuthRemoteDataSourceImpl.getBaseApiUrl();

  CommunityRemoteDataSourceImpl({required this.client});

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<CommunityPostModel>> getPosts() async {
    final headers = await _getAuthHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/community/posts'), 
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CommunityPostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load community posts. Status: ${response.statusCode}');
    }
  }

  @override
  Future<List<CommunityPostModel>> getMyPosts() async {
    final headers = await _getAuthHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/community/posts/my'), // API endpoint for user's own posts
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CommunityPostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user posts. Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> createPost(String title, String content, List<String>? imageUrls, List<String>? videoUrls, String? userAvatarUrl) async {
    final headers = await _getAuthHeaders();
    final body = {
      'title': title,
      'content': content,
      if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      if (videoUrls != null && videoUrls.isNotEmpty) 'videoUrls': videoUrls,
      if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
    };
    
    final response = await client.post(
      Uri.parse('$_baseUrl/community/posts'), 
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post. Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> deletePost(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await client.delete(
      Uri.parse('$_baseUrl/community/posts/$postId'), 
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post. Status: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> favoritePost(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/community/posts/$postId/favorite'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to favorite post');
    }
  }

  @override
  Future<Map<String, dynamic>> dislikePost(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/community/posts/$postId/dislike'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to dislike post');
    }
  }

  @override
  Future<Map<String, dynamic>> likePost(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/community/posts/$postId/like'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to like post');
    }
  }

  @override
  Future<List<CommunityPostModel>> getFavoritePosts() async {
    final headers = await _getAuthHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/community/posts/favorites'), 
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => CommunityPostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorite posts. Status: ${response.statusCode}');
    }
  }
}
