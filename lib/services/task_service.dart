import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'api_client.dart';

class TaskService {
  Future<http.Response> _get(String path) async {
    try {
      return await ApiClient.get(path).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Không kết nối được máy chủ. Kiểm tra server và mạng.');
    }
  }

  String _message(http.Response r) {
    try {
      final body = jsonDecode(r.body);
      if (body is Map && body['message'] != null) return body['message'].toString();
    } catch (_) {}
    return 'Lỗi ${r.statusCode}';
  }

  Future<List<Task>> getTasks({String? scope}) async {
    final query = scope == null ? '' : '?scope=$scope';
    final response = await _get('/tasks$query');
    if (response.statusCode != 200) throw Exception(_message(response));

    final List data = jsonDecode(response.body);
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> getTaskById(String id) async {
    final response = await _get('/tasks/$id');
    if (response.statusCode != 200) throw Exception(_message(response));

    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}