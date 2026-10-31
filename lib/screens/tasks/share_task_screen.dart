import 'package:flutter/material.dart';
import '../../models/task_share.dart';
import '../../services/share_service.dart';
import '../../widgets/user_search_sheet.dart';

const Map<String, String> _permLabels = {
  'viewer': 'Chỉ xem',
  'editor': 'Được chỉnh sửa',
};

class ShareTaskScreen extends StatefulWidget {
  final String taskId;
  const ShareTaskScreen({super.key, required this.taskId});

  @override
  State<ShareTaskScreen> createState() => _ShareTaskScreenState();
}

class _ShareTaskScreenState extends State<ShareTaskScreen> {
  final _service = ShareService();
  List<TaskShare> _shares = [];
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
      final r = await _service.getShares(widget.taskId);
      if (!mounted) return;
      setState(() => _shares = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _msg(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Thuc hien mot thao tac roi tai lai danh sach
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      final r = await _service.getShares(widget.taskId);
      if (!mounted) return;
      setState(() => _shares = r);
    } catch (e) {
      if (!mounted) return;
      _toast(_msg(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final user = await pickUser(context, title: 'Chọn người để chia sẻ');
    if (user == null || !mounted) return;

    final permission = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Chia sẻ cho ${user.fullName}'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'viewer'),
            child: const Text('Chỉ xem (viewer)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'editor'),
            child: const Text('Được chỉnh sửa (editor)'),
          ),
        ],
      ),
    );
    if (permission == null || !mounted) return;

    await _run(() => _service.addShare(widget.taskId, user.id, permission));
  }

  Future<void> _remove(TaskShare s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hồi chia sẻ'),
        content: Text('Thu hồi quyền của ${s.user?.fullName ?? 'người này'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() => _service.removeShare(widget.taskId, s.id));
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
    if (_shares.isEmpty) {
      return const Center(child: Text('Chưa chia sẻ cho ai'));
    }
    return ListView.separated(
      itemCount: _shares.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = _shares[i];
        final name = s.user?.fullName ?? '?';
        return ListTile(
          leading: CircleAvatar(
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
          ),
          title: Text(name),
          subtitle: Text(s.user?.email ?? ''),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                enabled: !_busy,
                tooltip: 'Đổi quyền',
                onSelected: (p) {
                  if (p != s.permission) {
                    _run(() => _service.updatePermission(widget.taskId, s.id, p));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'viewer', child: Text('Chỉ xem')),
                  PopupMenuItem(value: 'editor', child: Text('Được chỉnh sửa')),
                ],
                child: Chip(label: Text(_permLabels[s.permission] ?? s.permission)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _busy ? null : () => _remove(s),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ công việc')),
      body: Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
          Expanded(child: _body()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(Icons.share),
        label: const Text('Thêm người'),
      ),
    );
  }
}