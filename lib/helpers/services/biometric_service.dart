import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> isSupported() async {
    return _localAuthentication.isDeviceSupported();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return _localAuthentication.getAvailableBiometrics();
  }

  Future<bool> hasEnrolledBiometrics() async {
    final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return false;
    }

    final biometrics = await getAvailableBiometrics();
    return biometrics.isNotEmpty;
  }

  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
