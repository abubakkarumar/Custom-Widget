import 'package:pointycastle/asymmetric/api.dart' as crypto;
import 'app_secure_storage.dart';
import 'package:basic_utils/basic_utils.dart';

class BiometricKeyService {
  static Future<void> generateAndStoreKeys() async {
    final pair = CryptoUtils.generateRSAKeyPair();

    final publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPem(pair.publicKey as crypto.RSAPublicKey);
    final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(pair.privateKey as crypto.RSAPrivateKey);

    // Strip headers and footers
    final rawPublicKey = _stripPemHeaders(publicKeyPem);
    final rawPrivateKey = _stripPemHeaders(privateKeyPem);

    await AppSecureStorage.storePublicKey(rawPublicKey);
    await AppSecureStorage.storePrivateKey(rawPrivateKey);
  }

  static String _stripPemHeaders(String pem) {
    final lines = pem.split('\n');
    final base64Lines = lines.where((line) =>
    !line.startsWith('-----BEGIN') &&
        !line.startsWith('-----END') &&
        line.trim().isNotEmpty);
    return base64Lines.join('');
  }
}
