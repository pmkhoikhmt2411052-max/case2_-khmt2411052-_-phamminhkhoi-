import 'user.dart';
import 'task_share.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? startDate;
  final DateTime? dueDate;
  final User? createdBy;
  final User? primaryAssignee;
  final List<User> assignees;
  final List<TaskShare> shares;
  final String? myRole;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.startDate,
    this.dueDate,
    this.createdBy,
    this.primaryAssignee,
    this.assignees = const [],
    this.shares = const [],
    this.myRole,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    User? parseUser(dynamic v) =>
        v is Map<String, dynamic> ? User.fromJson(v) : null;
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

    return Task(
      id: json['_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      startDate: parseDate(json['startDate']),
      dueDate: parseDate(json['dueDate']),
      createdBy: parseUser(json['createdBy']),
      primaryAssignee: parseUser(json['primaryAssigneeId']),
      assignees: ((json['assigneeIds'] as List?) ?? [])
          .map(parseUser)
          .whereType<User>()
          .toList(),
      shares: ((json['shares'] as List?) ?? [])
          .map((e) => TaskShare.fromJson(e as Map<String, dynamic>))
          .toList(),
      myRole: json['myRole'],
    );
  }
}