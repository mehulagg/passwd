import 'package:injectable/injectable.dart';
import 'package:supercharged/supercharged.dart';

import '../crypto/crypto_service.dart';
import '../locator.dart';
import '../secure_kv/secure_kv.dart';
import 'authentication_service.dart';

@LazySingleton(as: AuthenticationService)
class AuthenticationImpl implements AuthenticationService {
  final String key = "ENCRYPTION_KEY";
  final String biometricsKey = "ALLOW_BIOMETRICS";

  final CryptoService crypto = locator<CryptoService>();
  final SecureKVService kv = locator<SecureKVService>();

  @override
  Future<bool> comparePin(int pin) async {
    String s256 = crypto.sha512(pin.toString());
    String encryptionKey = await kv.getValue(key);

    return s256 == encryptionKey;
  }

  @override
  Future<String> readEncryptionKey() async {
    return await kv.getValue(key);
  }

  @override
  Future writePin(int pin) async {
    String encryptionKey = crypto.sha512(pin.toString());
    await kv.putValue(key, encryptionKey);
  }

  @override
  Future<bool> allowBiometrics() async {
    return (await kv.getValue(biometricsKey)).toInt() == 1 ? true : false;
  }

  @override
  Future writeBiometrics(bool allow) async {
    await kv.putValue(biometricsKey, allow ? "1" : "0");
  }
}
