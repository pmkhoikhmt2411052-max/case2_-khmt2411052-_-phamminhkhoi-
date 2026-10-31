import 'package:flutter/material.dart';
import '../../models/task_assignee.dart';
import '../../services/assignment_service.dart';
import '../../widgets/user_search_sheet.dart';

class AssignTaskScreen extends StatefulWidget {
  final String taskId;
  const AssignTaskScreen({super.key, required this.taskId});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _service = AssignmentService();
  List<TaskAssignee> _assignees = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _service.getAssignees(widget.taskId);
      if (!mounted) return;
      setState(() => _assignees = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _msg(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<List<TaskAssignee>> Function() action) async {
    setState(() => _busy = true);
    try {
      final r = await action();
      if (!mounted) return;
      setState(() => _assignees = r);
    } catch (e) {
      if (!mounted) return;
      _toast(_msg(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final user = await pickUser(context, title: 'Chọn người được giao');
    if (user == null || !mounted) return;
    if (_assignees.any((a) => a.id == user.id)) {
      _toast('${user.fullName} đã được giao việc này');
      return;
    }
    await _run(() => _service.addAssignees(widget.taskId, [user.id]));
  }

  Future<void> _remove(TaskAssignee a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy giao việc'),
        content: Text('Hủy giao việc cho ${a.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy giao'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() => _service.removeAssignee(widget.taskId, a.id));
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }
    if (_assignees.isEmpty) {
      return const Center(child: Text('Chưa giao việc cho ai'));
    }
    return ListView.separated(
      itemCount: _assignees.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final a = _assignees[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(a.fullName.isEmpty ? '?' : a.fullName[0].toUpperCase()),
          ),
          title: Text(a.fullName),
          subtitle: Text(a.isPrimary ? '${a.email}\nNgười phụ trách chính' : a.email),
          isThreeLine: a.isPrimary,
          trailing: PopupMenuButton<String>(
            enabled: !_busy,
            onSelected: (v) {
              if (v == 'primary') {
                _run(() => _service.setPrimary(widget.taskId, a.id));
              } else if (v == 'remove') {
                _remove(a);
              }
            },
            itemBuilder: (_) => [
              if (!a.isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Text('Đặt làm người phụ trách chính'),
                ),
              const PopupMenuItem(value: 'remove', child: Text('Hủy giao việc')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao việc')),
      body: Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
          Expanded(child: _body()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm người'),
      ),
    );
  }
}