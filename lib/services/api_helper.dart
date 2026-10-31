import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

/// Goi API co dinh kem token. Tra ve du lieu JSON; nem Exception(message) neu loi.
Future<dynamic> apiRequest(String method, String path,
    {Map<String, dynamic>? body}) async {
  final token = await ApiClient.getToken();
  final request = http.Request(method, Uri.parse('${ApiClient.baseUrl}$path'));
  request.headers['Content-Type'] = 'application/json; charset=utf-8';
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  if (body != null) request.body = jsonEncode(body);

  http.Response response;
  try {
    response = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 15)),
    );
  } catch (_) {
    throw Exception('Không kết nối được máy chủ. Kiểm tra server và mạng.');
  }

  dynamic data;
  try {
    data = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
  } catch (_) {}

  if (response.statusCode >= 200 && response.statusCode < 300) return data;

  final message = (data is Map && data['message'] != null)
      ? data['message'].toString()
      : 'Lỗi ${response.statusCode}';
  throw Exception(message);
}