import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _keyAccessToken = '@placfy_access_token';
  static const String _keyRefreshToken = '@placfy_refresh_token';
  static const String _keyActiveWorkspace = '@placfy_active_workspace';
  static const String _keyActiveEntityId = '@placfy_active_entity_id';
  static const String _keyActiveEntityName = '@placfy_active_entity_name';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveActiveWorkspace(String slug) async {
    await _storage.write(key: _keyActiveWorkspace, value: slug);
  }

  Future<String?> getActiveWorkspace() async {
    return await _storage.read(key: _keyActiveWorkspace);
  }

  Future<void> saveActiveEntity({
    required int entityId,
    required String entityName,
  }) async {
    await _storage.write(key: _keyActiveEntityId, value: entityId.toString());
    await _storage.write(key: _keyActiveEntityName, value: entityName);
  }

  Future<int?> getActiveEntityId() async {
    final val = await _storage.read(key: _keyActiveEntityId);
    if (val == null) return null;
    return int.tryParse(val);
  }

  Future<String?> getActiveEntityName() async {
    return await _storage.read(key: _keyActiveEntityName);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyActiveWorkspace);
    await _storage.delete(key: _keyActiveEntityId);
    await _storage.delete(key: _keyActiveEntityName);
  }
}
