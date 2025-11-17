import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/models/user_model.dart'; // We will create this model next

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> register(String email, String password, String verificationCode);
  Future<void> sendVerificationCode(String email);
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile({String? username, String? avatarUrl, String? bio});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'http://192.168.4.140:3000/api/auth';

  AuthRemoteDataSourceImpl({required this.client});

  static String getBaseApiUrl() => _baseUrl.substring(0, _baseUrl.lastIndexOf('/api')) + '/api';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<String> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      final errorBody = response.body;
      throw Exception('Failed to login. Status code: ${response.statusCode}, Body: $errorBody');
    }
  }

  // ... other existing methods (register, sendVerificationCode) ...

  @override
  Future<UserModel> getUserProfile() async {
    final headers = await _getAuthHeaders();
    final response = await client.get(
      Uri.parse('$_baseUrl/profile'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get user profile');
    }
  }

  @override
  Future<UserModel> updateProfile({String? username, String? avatarUrl, String? bio}) async {
    final headers = await _getAuthHeaders();
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (bio != null) body['bio'] = bio;

    final response = await client.put(
      Uri.parse('$_baseUrl/profile'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<void> register(String email, String password, String verificationCode) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<void> sendVerificationCode(String email) {
    // TODO: implement sendVerificationCode
    throw UnimplementedError();
  }
}
