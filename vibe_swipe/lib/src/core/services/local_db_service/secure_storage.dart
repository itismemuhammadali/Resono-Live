import '../../utils/app_exports.dart';

class Prefs {
  ///
  /// Pref Keys
  ///
  static const String _kUser = "user";
  static const String kAccessToken = "accessToken";

  // static const String _kUserSecrets = "userSecrets";

  final _secureStorage = locator<FlutterSecureStorage>();

  Future<void> store(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  ///
  /// Here we manage app configs
  ///
  Future<void> storeToken(String? token) async {
    try {
      await store(kAccessToken, token!);
    } catch (e) {
      appPrint('Failed to store token');
    }
  }

  Future<String?> fetchToken() async {
    try {
      return await read(kAccessToken);
    } catch (e) {
      throw ('Token not found');
    }
  }

  Future<void> deleteToken() async {
    try {
      await delete(kAccessToken);
    } catch (e) {
      appPrint('Failed to delete token');
    }
  }

  Future<void> storeUser(User? user) async {
    try {
      await store(_kUser, jsonEncode(user));
    } catch (e) {
      appPrint('User found null');
    }
  }

  Future<User?> fetchUser() async {
    try {
      String? user = await read(_kUser);
      return User.fromJson(jsonDecode(user!));
    } catch (e) {
      throw ('User not found');
    }
  }

  Future<void> deleteUser() async {
    try {
      await _secureStorage.delete(key: _kUser);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearStorage() async {
    await _secureStorage.deleteAll();
  }

  Future<void> storeList(String key, List<String> values) async {
    await _secureStorage.write(key: key, value: values.join(';'));
  }

  Future<List<String>?> readList(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value?.split(';');
  }
}


class User{
  final String id;
  final String name;
  final String email;
  final String? role;

  User({required this.id, required this.name, required this.email, this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}