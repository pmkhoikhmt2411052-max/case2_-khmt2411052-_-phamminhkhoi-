import '../models/user.dart';
import 'api_helper.dart';

class UserService {
  Future<List<User>> search(String query) async {
    final data = await apiRequest(
      'GET',
      '/users/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return (data as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}