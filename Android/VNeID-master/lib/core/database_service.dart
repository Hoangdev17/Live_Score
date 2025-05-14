import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class DatabaseService {
  static const _secureStorage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryptionKey_vneid';
  static const _userBoxName = 'user_data';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Lấy hoặc tạo encryption key
    final encryptionKey = await _getEncryptionKey();

    // Mở box với mã hóa
    await Hive.openBox(
      _userBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  static Future<List<int>> _getEncryptionKey() async {
    var keyString = await _secureStorage.read(key: _encryptionKeyName);

    if (keyString == null) {
      final key = Hive.generateSecureKey();
      keyString = base64Encode(key);
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: keyString,
      );
    }

    return base64Decode(keyString);
  }

  static Box get userBox => Hive.box(_userBoxName);
}