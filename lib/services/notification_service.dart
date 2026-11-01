import 'api_helper.dart';

class NotificationService {
  // Lấy danh sách thông báo
  Future<List<dynamic>> getNotifications() async {
    final data = await apiRequest('GET', '/notifications');
    return data is List ? data : (data['data'] ?? []);
  }

  // Đếm số thông báo chưa đọc
  Future<int> getUnreadCount() async {
    final data = await apiRequest('GET', '/notifications/unread-count');
    if (data is Map && data.containsKey('unreadCount')) {
      return data['unreadCount'] as int;
    }
    return 0;
  }

  // Đánh dấu 1 thông báo đã đọc
  Future<void> markAsRead(String id) async {
    await apiRequest('PATCH', '/notifications/$id/read');
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    await apiRequest('PATCH', '/notifications/read-all');
  }
}