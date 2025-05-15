import 'package:zenify_chat/api/users/get_all_users.dart';

class UserService {
   Future<List<String>> fetchAllUsernames() async {
    return await getAllUsers();
  }
}



//pagination
//backend should return 20 users at a time