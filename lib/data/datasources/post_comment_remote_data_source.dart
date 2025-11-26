import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/models/post_comment_model.dart';
import 'package:sport_flutter/data/datasources/auth_remote_data_source.dart';

abstract class PostCommentRemoteDataSource {
  Future<List<PostCommentModel>> getComments(int postId);
  Future<void> createComment(int postId, String content, {int? parentCommentId});
  Future<void> voteOnComment(int commentId, String voteType);
  Future<void> deleteComment(int commentId);
}

class PostCommentRemoteDataSourceImpl implements PostCommentRemoteDataSource {
  final http.Client client;
  final String _baseUrl = AuthRemoteDataSourceImpl.getBaseApiUrl();

  PostCommentRemoteDataSourceImpl({required this.client});

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<PostCommentModel>> getComments(int postId) async {
    final headers = await _getAuthHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/post-comments/$postId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => PostCommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load post comments. Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> createComment(int postId, String content, {int? parentCommentId}) async {
    final headers = await _getAuthHeaders();
    final body = {
      'postId': postId,
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await client.post(
      Uri.parse('$_baseUrl/post-comments'),
      headers: headers,
      body: json.encode(body),
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create comment. Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> voteOnComment(int commentId, String voteType) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/post-comments/$commentId/vote'),
      headers: headers,
      body: json.encode({'voteType': voteType}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to vote on comment. Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteComment(int commentId) async {
    final headers = await _getAuthHeaders();
    final response = await client.delete(
      Uri.parse('$_baseUrl/post-comments/$commentId'),
      headers: headers,
    );

    if (response.statusCode != 204) { // No Content
      throw Exception('Failed to delete comment. Status: ${response.statusCode}');
    }
  }
}
