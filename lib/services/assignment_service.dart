import '../models/task_assignee.dart';
import 'api_helper.dart';

class AssignmentService {
  List<TaskAssignee> _parse(dynamic data) => (data as List)
      .map((e) => TaskAssignee.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<List<TaskAssignee>> getAssignees(String taskId) async =>
      _parse(await apiRequest('GET', '/tasks/$taskId/assignees'));

  Future<List<TaskAssignee>> addAssignees(String taskId, List<String> userIds) async =>
      _parse(await apiRequest('POST', '/tasks/$taskId/assignees',
          body: {'userIds': userIds}));

  Future<List<TaskAssignee>> setPrimary(String taskId, String userId) async =>
      _parse(await apiRequest('PATCH', '/tasks/$taskId/assignees/$userId',
          body: {'isPrimary': true}));

  Future<List<TaskAssignee>> removeAssignee(String taskId, String userId) async =>
      _parse(await apiRequest('DELETE', '/tasks/$taskId/assignees/$userId'));
}