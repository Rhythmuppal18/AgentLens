import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class CryptoUtil {
  static final Random _secureRandom = Random.secure();
  static const _roomCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generateRoomCode() {
    final buffer = StringBuffer('AL-');
    for (int i = 0; i < 4; i++) {
      buffer.write(_roomCodeAlphabet[_secureRandom.nextInt(_roomCodeAlphabet.length)]);
    }
    return buffer.toString();
  }

  static String generateIngestToken() {
    final bytes = List<int>.generate(24, (_) => _secureRandom.nextInt(256));
    final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'agt_$hexStr';
  }

  static String generateParticipantToken() {
    final bytes = List<int>.generate(24, (_) => _secureRandom.nextInt(256));
    final hexStr = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'ptk_$hexStr';
  }

  static String hashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }
}
