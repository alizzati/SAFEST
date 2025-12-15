import 'api_service.dart';
import '../models/user_model.dart'; 

class UserService {
  final api = ApiService();

  Future<void> updateUser(User user) async {
    await api.put('/users/${user.id}', user.toJson());
  }
}

