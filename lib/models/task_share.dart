import 'user.dart';

class TaskShare {
  final String id;
  final User? user;
  final String permission;

  TaskShare({required this.id, required this.user, required this.permission});

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    return TaskShare(
      id: json['_id'].toString(),
      user: json['userId'] is Map<String, dynamic>
          ? User.fromJson(json['userId'])
          : null,
      permission: json['permission'] ?? 'viewer',
    );
  }
}