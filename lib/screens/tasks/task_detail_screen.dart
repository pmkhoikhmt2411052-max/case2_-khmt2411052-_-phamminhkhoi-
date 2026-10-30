import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import 'task_form_screen.dart';
class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> _future;

  @override
  void initState() {
    super.initState();
    _future = TaskService().getTaskById(widget.taskId);
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Chuyển sang form Sửa (có truyền ID)
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskFormScreen(taskId: widget.taskId)),
              );
              // Nếu sửa thành công, tải lại trang chi tiết
              if (result == true) {
                setState(() {
                  _future = TaskService().getTaskById(widget.taskId);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Gọi API xóa công việc
              await TaskService().deleteTask(widget.taskId);
              if (context.mounted) {
                Navigator.pop(context, true); // Xóa xong thì thoát ra màn hình ngoài
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(errorText(snapshot.error!), textAlign: TextAlign.center),
              ),
            );
          }

          final t = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(t.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                StatusBadge(t.status),
                PriorityBadge(t.priority),
              ]),
              const Divider(height: 32),
              _row('Mô tả', t.description),
              _row('Ngày bắt đầu', formatDate(t.startDate)),
              _row('Hạn hoàn thành', formatDate(t.dueDate)),
              _row('Người tạo', t.createdBy?.fullName ?? ''),
              _row('Người phụ trách chính', t.primaryAssignee?.fullName ?? ''),
              _row('Người được giao', t.assignees.map((u) => u.fullName).join(', ')),
              _row(
                'Người được chia sẻ',
                t.shares
                    .map((s) =>
                '${s.user?.fullName ?? '?'} (${roleLabels[s.permission] ?? s.permission})')
                    .join(', '),
              ),
              _row('Vai trò của bạn', roleLabels[t.myRole] ?? ''),
            ],
          );
        },
      ),
    );
  }
}