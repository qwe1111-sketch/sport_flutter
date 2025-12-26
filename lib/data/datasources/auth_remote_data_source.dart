import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_flutter/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<void> register(String username, String email, String password, String verificationCode);
  Future<void> sendVerificationCode(String email);
  Future<void> sendPasswordResetCode(String email);
  Future<void> resetPassword(String email, String code, String newPassword);
  Future<void> forgotPasswordSendCode(String username, String email);
  Future<void> forgotPasswordReset(String username, String email, String code, String newPassword);
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile({String? username, String? avatarUrl, String? bio});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'http://47.253.229.197:3030/api/auth';

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

  Exception _handleError(http.Response response) {
    final path = response.request?.url.path;
    if (path != null &&
        (path.endsWith('/send-code') ||
            path.endsWith('/send-reset-code') ||
            path.endsWith('/forgot-password/send-code'))) {
      return Exception('验证码发送失败，请稍后重试。');
    }
    try {
      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error'] ?? errorBody['message'] ?? 'An unknown error occurred';
      return Exception(errorMessage);
    } catch (e) {
      return Exception(
          'Failed to connect to the server. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<String> login(String username, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<void> register(String username, String email, String password, String verificationCode) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'code': verificationCode,
      }),
    );
    if (response.statusCode != 201) {
      throw _handleError(response);
    }
  }

  @override
  Future<void> sendVerificationCode(String email) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/send-code'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  @override
  Future<void> sendPasswordResetCode(String email) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/send-reset-code'),
      headers: headers,
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  @override
  Future<void> resetPassword(String email, String code, String newPassword) async {
    final headers = await _getAuthHeaders();
    final response = await client.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: headers,
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  @override
  Future<void> forgotPasswordSendCode(String username, String email) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/forgot-password/send-code'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'email': email}),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  @override
  Future<void> forgotPasswordReset(String username, String email, String code, String newPassword) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/forgot-password/reset'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

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
      throw _handleError(response);
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
      throw _handleError(response);
    }
  }
}
