import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final data = await _api.get('/users');
    try {
      final list = data as List<dynamic>;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TypeError catch (e) {
      throw BadResponseException('users: $e');
    } on FormatException catch (e) {
      throw BadResponseException('users: $e');
    }
  }

  Future<User> getById(int id) async {
    final data = await _api.get('/users/$id');
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } on TypeError catch (e) {
      throw BadResponseException('users/$id: $e');
    } on FormatException catch (e) {
      throw BadResponseException('users/$id: $e');
    }
  }

  Future<User> create(User draft) async {
    final data = await _api.post('/users', body: draft.toJson());
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } on TypeError catch (e) {
      throw BadResponseException('users/create: $e');
    } on FormatException catch (e) {
      throw BadResponseException('users/create: $e');
    }
  }
}
