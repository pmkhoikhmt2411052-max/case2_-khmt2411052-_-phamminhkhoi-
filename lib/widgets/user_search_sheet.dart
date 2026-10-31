import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// Mo bang tim nguoi dung (theo ten hoac email). Tra ve User duoc chon, hoac null.
Future<User?> pickUser(BuildContext context, {String title = 'Tìm người dùng'}) {
  return showModalBottomSheet<User>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _UserSearchSheet(title: title),
  );
}

class _UserSearchSheet extends StatefulWidget {
  final String title;
  const _UserSearchSheet({required this.title});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final _controller = TextEditingController();
  final _service = UserService();
  Timer? _debounce;
  List<User> _results = [];
  bool _loading = false;
  String? _error;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(value.trim()));
  }

  Future<void> _search(String q) async {
    _query = q;
    if (q.length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _service.search(q);
      if (!mounted || q != _query) return;
      setState(() => _results = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && q == _query) setState(() => _loading = false);
    }
  }

  Widget _buildResults() {
    if (_query.length < 2) {
      return const Center(child: Text('Nhập tên hoặc email để tìm'));
    }
    if (!_loading && _results.isEmpty && _error == null) {
      return const Center(child: Text('Không tìm thấy người dùng'));
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final u = _results[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(u.fullName.isEmpty ? '?' : u.fullName[0].toUpperCase()),
          ),
          title: Text(u.fullName),
          subtitle: Text(u.email),
          onTap: () => Navigator.pop(context, u),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.7;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onChanged,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Nhập tên hoặc email (ít nhất 2 ký tự)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }
}