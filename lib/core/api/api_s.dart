import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = '192.168.8.163:8000';

  String? _token;


  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_token ?? ''}',
  };

  Map<String, String> get _jsonHeaders => {
    ..._headers,
    'Content-Type': 'application/json',
  };

  Map<String, String> get _publicHeaders => {
    'Accept': 'application/json',
  };

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = null;
    await prefs.remove('token');
  }


  Future<http.Response> _get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    return await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));
  }

  Future<http.Response> _put(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return await http
        .put(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 15));
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    dynamic data;

    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw Exception("استجابة غير صالحة من السيرفر");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    if (response.statusCode == 401) {
      clearToken();
      throw Exception("انتهت الجلسة، يرجى تسجيل الدخول");
    }

    throw Exception(
      data is Map && data['message'] != null
          ? data['message']
          : "حدث خطأ غير متوقع",
    );
  }

  List<dynamic> _extractItems(dynamic data) {
    if (data == null) return [];

    if (data is List) return data;

    if (data is Map) {
      if (data['items'] is List) return data['items'];
      if (data['data'] is List) return data['data'];

      if (data['data'] is Map) {
        final nested = data['data'];
        if (nested['items'] is List) return nested['items'];
        if (nested['data'] is List) return nested['data'];
      }
    }

    return [];
  }

  Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      final url = Uri.http(_baseUrl, '/api/login');

      final response = await _post(
        url,
        headers: _publicHeaders,
        body: {
          'email': email,
          'password': password,
        },
      );

      final data = _handleResponse(response);

      final token = data['data']?['token'] ??
          data['token'] ??
          data['data']?['access_token'];

      if (token == null) {
        throw Exception("لم يتم العثور على التوكن");
      }

      await saveToken(token);

      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception("فشل تسجيل الدخول: $e");
    }
  }

  Future<void> logout() async {
    try {
      await loadToken();

      final url = Uri.http(_baseUrl, '/api/logout');

      await _post(
        url,
        headers: _headers,
      );
    } catch (_) {
      //
    } finally {
      await clearToken();
    }
  }


  Future<void> changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      ) async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/change-password');

    final response = await _post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    _handleResponse(response);
  }


  Future<Map<String, dynamic>> getDashboardStats() async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/student/dashboard-stats');

    final res = await _get(url, headers: _headers);

    return Map<String, dynamic>.from(_handleResponse(res));
  }


  Future<List<dynamic>> getOpportunities({int page = 1}) async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/opportunities',
      {'page': '$page'},
    );

    final res = await _get(url, headers: _headers);

    final data = _handleResponse(res);

    return _extractItems(data['data']);
  }

  Future<Map<String, dynamic>> getOpportunityDetails(int id) async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/opportunities/$id',
    );

    final res = await _get(url, headers: _headers);

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> applyToOpportunity(
      int id,
      String answers,
      String notes,
      ) async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/opportunities/$id/apply',
    );

    final res = await _post(
      url,
      headers: _headers,
      body: {
        'student_answers_block': answers,
        'student_notes': notes,
      },
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }


  Future<List<dynamic>> getMyRequests() async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/student/requests');

    final res = await _get(url, headers: _headers);

    final data = _handleResponse(res);

    return _extractItems(data['data']);
  }

  Future<Map<String, dynamic>> getTimeline() async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/student/timeline');

    final res = await _get(url, headers: _headers);

    return Map<String, dynamic>.from(_handleResponse(res));
  }


  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.http(_baseUrl, '/api/student/profile');
    final response = await http.get(url, headers: _headers);

    final decodedData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(decodedData);
    } else {
      throw Exception(decodedData['message'] ?? "خطأ في جلب البيانات");
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/student/profile');

    final res = await _put(
      url,
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<void> uploadProfilePhoto(String path) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/student/profile/photo'));
    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('photo', path));
    await request.send();
  }


  Future<Map<String, dynamic>> uploadDocument(
      String filePath,
      ) async {
    await loadToken();

    final url = Uri.http(_baseUrl, '/api/documents/upload');

    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(_headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return Map<String, dynamic>.from(_handleResponse(response));
  }


  Future<Map<String, dynamic>> getMyInternship() async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/my-internship',
    );

    final res = await _get(url, headers: _headers);

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> submitReport(
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/my-internship/reports',
    );

    final res = await _post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> getEvaluation() async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/my-internship/evaluation',
    );

    final res = await _get(url, headers: _headers);

    return Map<String, dynamic>.from(_handleResponse(res));
  }


  Future<List<dynamic>> getComplaints() async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/complaints',
    );

    final res = await _get(url, headers: _headers);

    final data = _handleResponse(res);

    return _extractItems(data['data']);
  }

  Future<Map<String, dynamic>> createComplaint(
      String title,
      String description,
      ) async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/student/complaints',
    );

    final res = await _post(
      url,
      headers: _headers,
      body: {
        'title': title,
        'description': description,
      },
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }


  Future<List<dynamic>> getNotifications() async {
    await loadToken();

    final url = Uri.http(
      _baseUrl,
      '/api/notifications',
    );

    final res = await _get(url, headers: _headers);

    final data = _handleResponse(res);

    return _extractItems(data['data']);
  }
}