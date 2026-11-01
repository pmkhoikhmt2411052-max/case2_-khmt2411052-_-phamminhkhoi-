import 'dart:convert';
import 'api_client.dart';

class StatisticsService {
  // Lấy thống kê theo trạng thái
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final response = await ApiClient.get('/statistics/tasks');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // Lấy thống kê công việc được giao
  Future<Map<String, dynamic>> getAssignmentStatistics() async {
    final response = await ApiClient.get('/statistics/assignments');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  // Lấy thống kê theo hạn hoàn thành
  Future<Map<String, dynamic>> getDeadlineStatistics() async {
    final response = await ApiClient.get('/statistics/deadlines');
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }
}