class TaskAssignee {
  final String id;
  final String fullName;
  final String email;
  final bool isPrimary;

  TaskAssignee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isPrimary,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) {
    return TaskAssignee(
      id: (json['id'] ?? json['_id']).toString(),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      isPrimary: json['isPrimary'] == true,
    );
  }
}