import 'dart:convert';
import 'api_client.dart';
import '../models/task.dart';

class TaskService {
  // Bóc tách dữ liệu: nếu backend trả về { "data": ... } thì lấy phần data
  dynamic _unwrap(String body) {
    final decoded = jsonDecode(body);
    return (decoded is Map && decoded.containsKey('data'))
        ? decoded['data']
        : decoded;
  }

  // Lấy danh sách công việc (Hỗ trợ scope, q, sortBy, order)
  Future<List<Task>> getTasks({
    String? scope,
    String? q,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, String>{};
    if (scope != null && scope.isNotEmpty) queryParams['scope'] = scope;
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (order != null && order.isNotEmpty) queryParams['order'] = order;

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/tasks${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await ApiClient.get(endpoint);
    final decoded = jsonDecode(response.body);

    final List<dynamic> data = decoded is List ? decoded : decoded['data'];
    return data.map((json) => Task.fromJson(json)).toList();
  }

  // Lấy chi tiết một công việc theo ID
  Future<Task> getTaskById(String taskId) async {
    final response = await ApiClient.get('/tasks/$taskId');
    return Task.fromJson(_unwrap(response.body));
  }

  // 1. Tạo công việc mới
  Future<dynamic> createTask(Map<String, dynamic> taskData) async {
    final response = await ApiClient.post('/tasks', taskData);
    return _unwrap(response.body);
  }

  // 2. Sửa công việc
  Future<dynamic> updateTask(String taskId, Map<String, dynamic> taskData) async {
    final response = await ApiClient.put('/tasks/$taskId', taskData);
    return _unwrap(response.body);
  }

  // 3. Xóa công việc
  Future<void> deleteTask(String taskId) async {
    await ApiClient.delete('/tasks/$taskId');
  }

  // 4. Giao việc cho người khác
  Future<dynamic> assignTask(String taskId, List<String> assignees) async {
    final response = await ApiClient.patch(
      '/tasks/$taskId/assignees',
      {'assignees': assignees},
    );
    return _unwrap(response.body);
  }

  // 5. Chia sẻ công việc (Viewer/Editor)
  Future<dynamic> shareTask(String taskId, List<Map<String, dynamic>> shares) async {
    final response = await ApiClient.patch(
      '/tasks/$taskId/shares',
      {'shares': shares},
    );
    return _unwrap(response.body);
  }
}