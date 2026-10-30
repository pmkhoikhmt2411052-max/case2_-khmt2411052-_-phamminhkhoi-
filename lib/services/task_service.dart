import 'dart:convert';
import 'api_client.dart';
import '../models/task.dart';
// Đừng quên import file model Task của bạn ở đây, ví dụ: import '../models/task.dart';

class TaskService {

  // ==============================================
  // HÃY COPY 2 HÀM GETTASKS VÀ GETTASKBYID TỪ CODE CŨ CỦA BẠN DÁN VÀO ĐÂY
  // ĐỂ GIAO DIỆN KHÔNG BỊ LỖI
  // ==============================================

  // 1. Tạo công việc mới
  Future<dynamic> createTask(Map<String, dynamic> taskData) async {
    final response = await ApiClient.post('/tasks', taskData);
    return jsonDecode(response.body)['data'];
  }

  // 2. Sửa công việc
  Future<dynamic> updateTask(String taskId, Map<String, dynamic> taskData) async {
    final response = await ApiClient.put('/tasks/$taskId', taskData);
    return jsonDecode(response.body)['data'];
  }

  // 3. Xóa công việc
  Future<void> deleteTask(String taskId) async {
    await ApiClient.delete('/tasks/$taskId');
  }

  // 4. Giao việc cho người khác
  Future<dynamic> assignTask(String taskId, List<String> assignees) async {
    final response = await ApiClient.patch('/tasks/$taskId/assignees', {'assignees': assignees});
    return jsonDecode(response.body);
  }

  // 5. Chia sẻ công việc (Viewer/Editor)
  Future<dynamic> shareTask(String taskId, List < Map < String, dynamic > > shares) async {
  final response = await ApiClient.patch('/tasks/$taskId/shares', {'shares': shares});
  return jsonDecode(response.body);
  }
  // Lấy danh sách công việc (tự động xử lý dạng List hoặc Map)
  Future<List<Task>> getTasks({String? scope}) async {
    String endpoint = '/tasks';
    if (scope != null && scope.isNotEmpty) {
      endpoint += '?scope=$scope';
    }
    final response = await ApiClient.get(endpoint);
    final decoded = jsonDecode(response.body);

    // Nếu là List thì dùng luôn, nếu là Map thì lấy ['data']
    final List<dynamic> data = decoded is List ? decoded : decoded['data'];

    return data.map((json) => Task.fromJson(json)).toList();
  }

  // Lấy chi tiết một công việc theo ID
  Future<Task> getTaskById(String taskId) async {
    final response = await ApiClient.get('/tasks/$taskId');
    final decoded = jsonDecode(response.body);

    // Xử lý tương tự cho object đơn
    final data = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;

    return Task.fromJson(data);
  }
}