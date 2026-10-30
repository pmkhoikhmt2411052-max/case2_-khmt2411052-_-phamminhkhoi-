import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/api_client.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../widgets/task_card.dart';
import '../auth/login_screen.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  static const Map<String?, String> _scopes = {
    null: 'Tất cả',
    'created': 'Tôi tạo',
    'assigned': 'Được giao',
    'shared': 'Được chia sẻ',
  };

  final _taskService = TaskService();
  String? _scope;
  late Future<List<Task>> _future;

  @override
  void initState() {
    super.initState();
    _future = _taskService.getTasks();
  }

  void _load() {
    setState(() {
      _future = _taskService.getTasks(scope: _scope);
    });
  }

  Future<void> _logout() async {
    await ApiClient.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Chuyển sang form Tạo mới
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
          // Nếu form trả về true (đã lưu), thì tải lại danh sách
          if (result == true) {
            _load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: _scopes.entries
                  .map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: _scope == e.key,
                  onSelected: (_) {
                    _scope = e.key;
                    _load();
                  },
                ),
              ))
                  .toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(errorText(snapshot.error!),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _load, child: const Text('Thử lại')),
                        ],
                      ),
                    ),
                  );
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(child: Text('Chưa có công việc nào'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => TaskCard(
                    task: tasks[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(taskId: tasks[i].id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
