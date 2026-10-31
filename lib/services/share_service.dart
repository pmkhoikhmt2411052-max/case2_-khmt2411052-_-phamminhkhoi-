import '../models/task_share.dart';
import 'api_helper.dart';

class ShareService {
  List<TaskShare> _parse(dynamic data) => (data as List)
      .map((e) => TaskShare.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<List<TaskShare>> getShares(String taskId) async =>
      _parse(await apiRequest('GET', '/tasks/$taskId/shares'));

  Future<void> addShare(String taskId, String userId, String permission) async {
    await apiRequest('POST', '/tasks/$taskId/shares', body: {
      'userIds': [userId],
      'permission': permission,
    });
  }

  Future<void> updatePermission(String taskId, String shareId, String permission) async {
    await apiRequest('PATCH', '/tasks/$taskId/shares/$shareId',
        body: {'permission': permission});
  }

  Future<void> removeShare(String taskId, String shareId) async {
    await apiRequest('DELETE', '/tasks/$taskId/shares/$shareId');
  }
}