import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
static const String baseUrl = 'http://192.168.232.223:8000';

  static String? _token;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $_token');
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('Token cleared');
  }

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email, 
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      final data =  jsonDecode(response.body);
      
      if(data['token'] != null) {
        await setToken(data['token']);
      }
      return data;
      
    } else {
      throw Exception('Failed to log in: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> verifylogin() async {
    
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/verifylogin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify login: ${response.body}');
    }
  }
  
  static Future<void> logout() async {
    await clearToken();
  }
}
