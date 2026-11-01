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

  // Bổ sung: Đổi mật khẩu tài khoản
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await apiRequest(
      'PUT',
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}