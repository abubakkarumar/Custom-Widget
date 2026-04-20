import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureStorage {
  static const _privateKeyKey = 'rsa_private_key';
  static const _publicKeyKey = 'rsa_public_key';
  static final _storage = FlutterSecureStorage();

  static Future<void> storePrivateKey(String privateKey) async {
    await _storage.write(key: _privateKeyKey, value: privateKey);
  }

  static Future<void> storePublicKey(String publicKey) async {
    await _storage.write(key: _publicKeyKey, value: publicKey);
  }

  static Future<String?> getPrivateKey() async {
    return await _storage.read(key: _privateKeyKey);
  }

  static Future<String?> getPublicKey() async {
    return await _storage.read(key: _publicKeyKey);
  }
}
