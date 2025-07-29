import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Authentication
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: await _getHeaders(),
        body: json.encode({'phoneNumber': phoneNumber}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }
  
  static Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: await _getHeaders(),
        body: json.encode({
          'phoneNumber': phoneNumber,
          'otp': otp,
        }),
      );
      
      final result = _handleResponse(response);
      if (result['success'] && result['token'] != null) {
        await saveToken(result['token']);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
  
  static Future<Map<String, dynamic>> logout() async {
    try {
      await removeToken();
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
  
  // User Profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(userData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
  
  // Posts
  static Future<Map<String, dynamic>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(postData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
  
  static Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }
  
  static Future<Map<String, dynamic>> addComment(String postId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode({'content': content}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
  
  // Emergency Alerts
  static Future<Map<String, dynamic>> getEmergencyAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emergency/alerts'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get emergency alerts: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createEmergencyAlert(Map<String, dynamic> alertData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency/alerts'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(alertData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create emergency alert: $e');
    }
  }
  
  // Events
  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }
  
  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode(eventData),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }
  
  static Future<Map<String, dynamic>> joinEvent(String eventId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/join'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }
  
  // Trust Circle
  static Future<Map<String, dynamic>> getTrustCircle() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trust-circle'),
        headers: await _getHeaders(includeAuth: true),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get trust circle: $e');
    }
  }
  
  static Future<Map<String, dynamic>> addToTrustCircle(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trust-circle/add'),
        headers: await _getHeaders(includeAuth: true),
        body: json.encode({'phoneNumber': phoneNumber}),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to add to trust circle: $e');
    }
  }
  
  // File Upload
  static Future<Map<String, dynamic>> uploadFile(File file, String type) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/$type'),
      );
      
      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Unknown error occurred');
    }
  }
}
