import 'package:flutter/material.dart';
import '../../services/statistics_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StatisticsService _statsService = StatisticsService();
  bool _isLoading = true;
  Map<String, dynamic> _taskStats = {};
  Map<String, dynamic> _deadlineStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final tasks = await _statsService.getTaskStatistics();
      final deadlines = await _statsService.getDeadlineStatistics();
      setState(() {
        _taskStats = tasks;
        _deadlineStats = deadlines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân & Thống kê'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê công việc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Cần làm', '${_taskStats['todo'] ?? 0}', Colors.orange),
                _buildStatCard('Đang làm', '${_taskStats['in_progress'] ?? 0}', Colors.blue),
                _buildStatCard('Hoàn thành', '${_taskStats['completed'] ?? 0}', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard('Sắp đến hạn', '${_deadlineStats['upcoming'] ?? 0}', Colors.amber),
                _buildStatCard('Quá hạn', '${_deadlineStats['overdue'] ?? 0}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}