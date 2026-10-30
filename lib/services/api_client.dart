import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  // Dùng 10.0.2.2 để máy ảo Android kết nối được với localhost của máy tính
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static String? _token;

  static File get _tokenFile =>
      File('${Directory.systemTemp.path}${Platform.pathSeparator}auth_token.txt');

  /// Lấy token (ưu tiên bộ nhớ, nếu chưa có thì đọc từ file)
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    try {
      if (await _tokenFile.exists()) {
        final saved = (await _tokenFile.readAsString()).trim();
        if (saved.isNotEmpty) _token = saved;
      }
    } catch (_) {}
    return _token;
  }

  /// Lưu token sau khi đăng nhập / đăng ký
  static Future<void> saveToken(String token) async {
    _token = token;
    try {
      await _tokenFile.writeAsString(token);
    } catch (_) {}
  }

  /// Xóa token khi đăng xuất
  static Future<void> clearToken() async {
    _token = null;
    try {
      if (await _tokenFile.exists()) await _tokenFile.delete();
    } catch (_) {}
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await getToken() ?? '';
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await getToken();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}