import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

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

  bool _isLoading = false;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadExistingData();
    }
  }

  // Tự động tải dữ liệu cũ nếu là chế độ Sửa
  Future<void> _loadExistingData() async {
    setState(() => _isFetching = true);
    try {
      final task = await TaskService().getTaskById(widget.taskId!);
      _titleController.text = task.title;
      _descController.text = task.description;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text,
        'description': _descController.text,
      };

      if (widget.taskId == null) {
        await TaskService().createTask(data); // Gọi API Tạo
      } else {
        await TaskService().updateTask(widget.taskId!, data); // Gọi API Sửa
      }

      if (mounted) {
        Navigator.pop(context, true); // Trở về và báo là đã lưu thành công (true)
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Tạo công việc' : 'Sửa công việc'),
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên công việc'),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập tên công việc' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả (tùy chọn)'),
                maxLines: 3,
              ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}