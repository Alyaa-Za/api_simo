import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'https://trainex.aladdiniot.com';

  String? _token;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (_token != null && _token!.isNotEmpty)
      'Authorization': 'Bearer $_token',
  };

  Map<String, String> get _jsonHeaders => {
    ..._headers,
    'Content-Type': 'application/json',
  };

  Map<String, String> get _publicHeaders => {
    'Accept': 'application/json',
  };


  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$_baseUrl$path').replace(
      queryParameters:
      query?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

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
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return await http
        .post(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _put(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return await http
        .put(url, headers: headers, body: body)
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _patch(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
      }) {
    return http.patch(
      url,
      headers: headers,
      body: body,
    );
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    dynamic data = {};

    try {
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401) {
      clearToken();
      throw Exception("انتهت الجلسة، يرجى تسجيل الدخول");
    }

    if (response.statusCode == 403 &&
        data is Map &&
        data['data'] != null &&
        data['data']['requires_password_change'] == true) {
      throw Exception("FORCE_PASSWORD_CHANGE");
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
        if (data['data']['items'] is List) return data['data']['items'];
        if (data['data']['data'] is List) return data['data']['data'];
      }
    }

    return [];
  }

  // LOGIN (يدعم الرقم الأكاديمي أو الإيميل)
  Future<Map<String, dynamic>> login(
      String login,
      String password,
      ) async {
    final response = await _post(
      _uri('/api/login'),
      headers: _publicHeaders,
      body: {
        'email': login,
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
  }

  Future<Map<String, dynamic>> registerInstitution(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    } else {
      // إرجاع رسالة الخطأ القادمة من الباك أند (مثل: الإيميل مستخدم مسبقاً)
      throw Exception(responseData['message'] ?? "فشل عملية التسجيل");
    }
  }


  Future<void> logout() async {
    try {
      await loadToken();
      await _post(
        _uri('/api/logout'),
        headers: _headers,
      );
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

    final response = await _post(
      _uri('/api/change-password'),
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

    final res = await _get(
      _uri('/api/student/dashboard-stats'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<List<dynamic>> getOpportunities({int page = 1}) async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/opportunities', {'page': page}),
      headers: _headers,
    );

    final data = _handleResponse(res);
    return _extractItems(data);
  }

  Future<Map<String, dynamic>> getOpportunityDetails(int id) async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/opportunities/$id'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> applyToOpportunity(
      int id,
      String answers,
      String notes,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/student/opportunities/$id/apply'),
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

    final res = await _get(
      _uri('/api/student/requests'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

  Future<Map<String, dynamic>> getTimeline() async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/timeline'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> getProfile() async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/profile'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final res = await _put(
      _uri('/api/student/profile'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<void> uploadProfilePhoto(String path) async {
    await loadToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/student/profile/photo'),
    );

    request.headers.addAll(_headers);

    request.files.add(
      await http.MultipartFile.fromPath('photo', path),
    );

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    _handleResponse(result);
  }

  Future<Map<String, dynamic>> uploadDocument(String filePath) async {
    await loadToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/documents/upload'),
    );

    request.headers.addAll(_headers);

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return Map<String, dynamic>.from(_handleResponse(response));
  }

  Future<Map<String, dynamic>> getMyInternship() async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/my-internship'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<Map<String, dynamic>> submitReport({
    required String title,
    required String content,
    required int weekNumber,
    required String filePath, // المسار الجديد للملف المطلوب
  }) async {
    await loadToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/student/my-internship/reports'),
    );

    request.headers.addAll(_headers);

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['week_number'] = weekNumber.toString();
    request.fields['submitted_by'] = "student";

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return Map<String, dynamic>.from(_handleResponse(response));
  }


  Future<Map<String, dynamic>> getEvaluation() async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/my-internship/evaluation'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

  Future<List<dynamic>> getComplaints() async {
    await loadToken();

    final res = await _get(
      _uri('/api/student/complaints'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

  Future<Map<String, dynamic>> createComplaint(
      String title,
      String description,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/student/complaints'),
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

    final res = await _get(
      _uri('/api/notifications'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }


  // ==============================
// Institution API Calls (مصححة)
// استبدل القسم كامل من getInstitutionProfile
// إلى resendVerificationCode
// ==============================

// 1) جلب بيانات المؤسسة
  Future<Map<String, dynamic>> getInstitutionProfile() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/profile'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 2) تحديث بيانات المؤسسة
  Future<Map<String, dynamic>> updateInstitutionProfile(
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final res = await _put(
      _uri('/api/institution/profile'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 3) رفع شعار المؤسسة
  Future<Map<String, dynamic>> uploadInstitutionLogo(String path) async {
    await loadToken();

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/institution/profile/logo'),
    );

    request.headers.addAll(_headers);

    request.files.add(
      await http.MultipartFile.fromPath('logo', path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return Map<String, dynamic>.from(_handleResponse(response));
  }

// 4) إحصائيات لوحة المؤسسة
  Future<Map<String, dynamic>> getInstitutionDashboardStats() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/dashboard-stats'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 5) الفرص الخاصة بالمؤسسة
  Future<List<dynamic>> getInstitutionOpportunities() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/opportunities'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

// 6) إنشاء فرصة تدريب
  Future<Map<String, dynamic>> createInstitutionOpportunity(
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/institution/opportunities'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 7) تفاصيل فرصة
  Future<Map<String, dynamic>> getInstitutionOpportunityDetails(
      int id,
      ) async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/opportunities/$id'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 8) تعديل فرصة
  Future<Map<String, dynamic>> updateInstitutionOpportunity(
      int id,
      Map<String, dynamic> body,
      ) async {
    await loadToken();

    final res = await _put(
      _uri('/api/institution/opportunities/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 9) تغيير حالة الفرصة
  Future<Map<String, dynamic>> changeOpportunityStatus(
      int id,
      String status,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/institution/opportunities/$id/status'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'status': status,
      }),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 10) الطلبات الواردة
  Future<List<dynamic>> getInstitutionRequests() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/requests'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

// 11) تفاصيل طلب
  Future<Map<String, dynamic>> getInstitutionRequestDetails(
      int id,
      ) async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/requests/$id'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 12) قبول طلب
  Future<Map<String, dynamic>> acceptInstitutionRequest(int id) async {
    await loadToken();

    final res = await _patch(
      _uri('/api/institution/requests/$id/accept'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 13) رفض طلب
  Future<Map<String, dynamic>> rejectInstitutionRequest(
      int id,
      String notes,
      ) async {
    await loadToken();

    final res = await _patch(
      _uri('/api/institution/requests/$id/reject'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'institution_notes': notes,
      }),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 14) المتدربين الحاليين
  Future<List<dynamic>> getInstitutionInternships() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/internships'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

// 15) تقارير متدرب
  Future<List<dynamic>> getInternshipReports(
      int id,
      ) async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/internships/$id/reports'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

// 16) تقييم متدرب
  Future<Map<String, dynamic>> evaluateInternship(
      int id,
      int score,
      String notes,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/institution/internships/$id/evaluate'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'score': score,
        'notes': notes,
      }),
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 17) شكاوى المؤسسة
  Future<List<dynamic>> getInstitutionComplaints() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/complaints'),
      headers: _headers,
    );

    return _extractItems(_handleResponse(res));
  }

// 18) إنشاء شكوى مؤسسة
  Future<Map<String, dynamic>> createInstitutionComplaint(
      String title,
      String description,
      ) async {
    await loadToken();

    final res = await _post(
      _uri('/api/institution/complaints'),
      headers: _headers,
      body: {
        'title': title,
        'description': description,
      },
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }

// 19) المتدربين النشطين
  Future<List<dynamic>> getActiveInterns() async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/internships'),
      headers: _headers,
    );

    final items = _extractItems(_handleResponse(res));

    return items.where((item) {
      if (item is Map<String, dynamic>) {
        final status = item['status']?.toString().toLowerCase();

        return status == 'active' ||
            status == 'ongoing' ||
            status == 'approved';
      }
      return false;
    }).toList();
  }

// 20) تأكيد كود التسجيل
  Future<Map<String, dynamic>> verifyRegistrationCode(
      String token,
      String code,
      ) async {
    final response = await _post(
      _uri('/api/register/verify-code'),
      headers: _jsonHeaders,
      body: jsonEncode({
        "verification_token": token,
        "code": code,
      }),
    );

    return Map<String, dynamic>.from(_handleResponse(response));
  }

  Future<Map<String, dynamic>> resendVerificationCode(
      String token,
      ) async {
    final response = await _post(
      _uri('/api/register/resend-code'),
      headers: _jsonHeaders,
      body: jsonEncode({
        "verification_token": token,
      }),
    );

    return Map<String, dynamic>.from(_handleResponse(response));

  }


  Future<Map<String, dynamic>> getInternshipDetails(int id) async {
    await loadToken();

    final res = await _get(
      _uri('/api/institution/internships/$id'),
      headers: _headers,
    );

    return Map<String, dynamic>.from(_handleResponse(res));
  }
}