import 'package:worklink_local/helpers/helpers.dart';
import 'package:worklink_local/modules/users/models/user_model.dart';

class LoginResult {
  final UserModel user;
  final String message;
  final String token;

  const LoginResult({
    required this.user,
    required this.message,
    required this.token,
  });
}

class UserService {
  static Future<LoginResult> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    final result = await AuthService.login(email: email, password: password);

    return LoginResult(
      user: result.user,
      message: result.message,
      token: result.token,
    );
  }
}
