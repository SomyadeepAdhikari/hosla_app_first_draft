import 'dart:async';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;
  
  Future<void> initialize() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final result = await ApiService.getUserProfile();
        if (result['success']) {
          _currentUser = result['user'];
          _isAuthenticated = true;
          _authStateController.add(true);
        } else {
          await ApiService.removeToken();
          _isAuthenticated = false;
          _authStateController.add(false);
        }
      } catch (e) {
        await ApiService.removeToken();
        _isAuthenticated = false;
        _authStateController.add(false);
      }
    } else {
      _isAuthenticated = false;
      _authStateController.add(false);
    }
  }
  
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final result = await ApiService.sendOtp(phoneNumber);
      
      // In development mode, if OTP is returned in response, show it to user
      if (result['success'] && result['otp'] != null) {
        print('🔐 Development OTP: ${result['otp']}');
        result['developmentOtp'] = result['otp'];
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }
  
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final result = await ApiService.verifyOtp(phoneNumber, otp);
      
      if (result['success']) {
        _currentUser = result['user'];
        _isAuthenticated = true;
        _authStateController.add(true);
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await ApiService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _authStateController.add(false);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData) async {
    try {
      final result = await ApiService.updateUserProfile(userData);
      
      if (result['success']) {
        _currentUser = result['user'];
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  void dispose() {
    _authStateController.close();
  }
}
