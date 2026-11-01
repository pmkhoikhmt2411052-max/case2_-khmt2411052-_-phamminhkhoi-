import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../tasks/task_detail_screen.dart';
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final _notificationService = NotificationService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = _notificationService.getNotifications();
    });
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllAsRead();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: _markAllRead,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Chưa có thông báo nào'));
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final isRead = item['isRead'] ?? item['read'] ?? false;
              final taskId = item['taskId'] ?? item['task']?['_id'];

              return ListTile(
                tileColor: isRead ? null : Colors.blue.withOpacity(0.05),
                leading: Icon(
                  isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: isRead ? Colors.grey : Colors.blue,
                ),
                title: Text(
                  item['title'] ?? item['message'] ?? 'Thông báo',
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(item['createdAt'] ?? ''),
                onTap: () async {
                  if (!isRead && item['_id'] != null) {
                    await _notificationService.markAsRead(item['_id']);
                  }
                  if (taskId != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(taskId: taskId.toString()),
                      ),
                    ).then((_) => _load());
                  } else {
                    _load();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}