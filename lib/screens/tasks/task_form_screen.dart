import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';

class TaskFormScreen extends StatefulWidget {
  final String? taskId; // Nếu null là Tạo mới, nếu có ID là Sửa
  const TaskFormScreen({super.key, this.taskId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _priority = 'medium';
  String _status = 'todo';
  DateTime? _start;
  DateTime? _due;

  bool _isLoading = false;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadExistingData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Tự động tải dữ liệu cũ nếu là chế độ Sửa
  Future<void> _loadExistingData() async {
    setState(() => _isFetching = true);
    try {
      final task = await TaskService().getTaskById(widget.taskId!);
      if (!mounted) return;
      _titleController.text = task.title;
      _descController.text = task.description;
      setState(() {
        _priority = task.priority;
        _status = task.status;
        _start = task.startDate;
        _due = task.dueDate;
      });
    } catch (e) {
      if (!mounted) return;
      _toast('Lỗi tải dữ liệu: ${_msg(e)}');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  String _iso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _start : _due) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _due = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start != null && _due != null && _due!.isBefore(_start!)) {
      _toast('Hạn hoàn thành phải sau ngày bắt đầu');
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Ngày để chuỗi rỗng nghĩa là xóa ngày đó
      final data = <String, String>{
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'priority': _priority,
        'status': _status,
        'startDate': _start == null ? '' : _iso(_start!),
        'dueDate': _due == null ? '' : _iso(_due!),
      };

      if (widget.taskId == null) {
        await TaskService().createTask(data); // Gọi API Tạo
      } else {
        await TaskService().updateTask(widget.taskId!, data); // Gọi API Sửa
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Trở về và báo là đã lưu thành công (true)
    } catch (e) {
      if (!mounted) return;
      _toast('Lỗi: ${_msg(e)}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _dateField(String label, DateTime? value, {required bool isStart}) {
    return InkWell(
      onTap: () => _pickDate(isStart: isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    if (isStart) {
                      _start = null;
                    } else {
                      _due = null;
                    }
                  }),
                ),
        ),
        child: Text(value == null ? 'Chưa chọn' : formatDate(value)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Tạo công việc' : 'Sửa công việc'),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tên công việc'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Vui lòng nhập tên công việc'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Mô tả (tùy chọn)'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Mức độ ưu tiên'),
                    items: priorityLabels.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _priority = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Trạng thái'),
                    items: statusLabels.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  _dateField('Ngày bắt đầu', _start, isStart: true),
                  const SizedBox(height: 16),
                  _dateField('Hạn hoàn thành', _due, isStart: false),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Lưu công việc'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}