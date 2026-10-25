const Map<String, String> statusLabels = {
  'todo': 'Chưa thực hiện',
  'in_progress': 'Đang thực hiện',
  'completed': 'Đã hoàn thành',
};

const Map<String, String> priorityLabels = {
  'low': 'Thấp',
  'medium': 'Trung bình',
  'high': 'Cao',
};

const Map<String, String> roleLabels = {
  'owner': 'Người tạo',
  'assignee': 'Người được giao',
  'viewer': 'Chỉ xem',
  'editor': 'Được chỉnh sửa',
};

String formatDate(DateTime? d) {
  if (d == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

String errorText(Object e) => e.toString().replaceFirst('Exception: ', '');