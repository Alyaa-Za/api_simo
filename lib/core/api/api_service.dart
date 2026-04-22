// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ApiService {
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();
//
//   static const String _baseUrl = '192.168.205.158:8000';
//
//   String? _token;
//
//   Map<String, String> get _headers => {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//       };
//
//   Map<String, String> get _publicHeaders => {
//         'Accept': 'application/json',
//       };
//
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final url = Uri.http(_baseUrl, '/api/login');
//
//     final prefs = await SharedPreferences.getInstance();
//
//     final response = await http.post(
//       url,
//       headers: _publicHeaders,
//       body: {
//         "email": email,
//         "password": password,
//       },
//     );
//
//     print("STATUS: ${response.statusCode}");
//     print("BODY: ${response.body}");
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       _token = data['data']['token'];
//
//       await prefs.setString('token', _token!
//           // 'user_name',
//           // data['data']['user']['full_name'] ?? '',
//           );
//
//       return data;
//     } else if (response.statusCode == 401) {
//       throw Exception(
//         data['message'] ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
//       );
//     } else if (response.statusCode == 422) {
//       throw Exception(
//         data['message'] ?? 'يرجى تعبئة جميع الحقول',
//       );
//     } else {
//       throw Exception('حدث خطأ غير متوقع');
//     }
//   }
//
//   Future<void> loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('token');
//   }
//
//   Future<void> logout() async {
//     final url = Uri.http(_baseUrl, '/api/logout');
//
//     await http.post(url, headers: _headers);
//     _token = null;
//   }
//
//   Future<Map<String, dynamic>> getDashboardStats() async {
//     final url = Uri.http(_baseUrl, '/api/student/dashboard-stats');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<List<dynamic>> getOpportunities({int page = 1}) async {
//     final url = Uri.http(
//       _baseUrl,
//       '/api/student/opportunities',
//       {'page': page.toString()},
//     );
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data['data'];
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> getOpportunityDetails(int id) async {
//     final url = Uri.http(_baseUrl, '/api/student/opportunities/$id');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> applyToOpportunity(
//     int id,
//     String answers,
//     String notes,
//   ) async {
//     final url = Uri.http(_baseUrl, '/api/student/opportunities/$id/apply');
//
//     final response = await http.post(
//       url,
//       headers: _headers,
//       body: {
//         'student_answers_block': answers,
//         'student_notes': notes,
//       },
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 201) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<List<dynamic>> getMyRequests() async {
//     final url = Uri.http(_baseUrl, '/api/student/requests');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data['data'] ?? data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> getTimeline() async {
//     final url = Uri.http(_baseUrl, '/api/student/timeline');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> getProfile() async {
//     final url = Uri.http(_baseUrl, '/api/student/profile');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
//     final url = Uri.http(_baseUrl, '/api/student/profile');
//
//     final response = await http.put(
//       url,
//       headers: {
//         ..._headers,
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> uploadCV(String filePath) async {
//     final url = Uri.http(_baseUrl, '/api/student/profile/cv');
//
//     final request = http.MultipartRequest('POST', url);
//     request.headers.addAll(_headers);
//
//     request.files.add(await http.MultipartFile.fromPath('cv', filePath));
//
//     final response = await request.send();
//     final res = await http.Response.fromStream(response);
//     final data = jsonDecode(res.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> getMyInternship() async {
//     final url = Uri.http(_baseUrl, '/api/student/my-internship');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> submitReport(Map<String, dynamic> body) async {
//     final url = Uri.http(_baseUrl, '/api/student/my-internship/reports');
//
//     final response = await http.post(
//       url,
//       headers: {
//         ..._headers,
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(body),
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 201) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> getEvaluation() async {
//     final url = Uri.http(_baseUrl, '/api/student/my-internship/evaluation');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<List<dynamic>> getComplaints() async {
//     final url = Uri.http(_baseUrl, '/api/student/complaints');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data['data'] ?? data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<Map<String, dynamic>> createComplaint(
//       String title, String description) async {
//     final url = Uri.http(_baseUrl, '/api/student/complaints');
//
//     final response = await http.post(
//       url,
//       headers: _headers,
//       body: {
//         'title': title,
//         'description': description,
//       },
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 201) {
//       return data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
//
//   Future<List<dynamic>> getNotifications() async {
//     final url = Uri.http(_baseUrl, '/api/notifications');
//
//     final response = await http.get(url, headers: _headers);
//     final data = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return data['data'] ?? data;
//     } else {
//       throw Exception(data['message']);
//     }
//   }
// }
