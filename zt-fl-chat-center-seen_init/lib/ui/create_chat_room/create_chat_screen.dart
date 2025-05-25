import 'package:flutter/material.dart';
import 'package:zenify_chat/services/user_service.dart';
import 'package:zenify_chat/ui/create_chat_room/utils/room_creation_handler.dart';
import 'package:zenify_chat/ui/create_chat_room/widgets/room_name_input.dart';
import 'package:zenify_chat/ui/create_chat_room/widgets/user_list.dart';
import 'package:zenify_chat/ui/create_chat_room/widgets/screen_header.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final TextEditingController roomNameController = TextEditingController();
  final UserService _userService = UserService();

  List<String> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      users = await _userService.fetchAllUsernames();
    } catch (e) {
      print("❌ Error fetching users: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleUserTap(String matrixId) {
    handleRoomCreation(
      context: context,
      roomNameController: roomNameController,
      inviteeMatrixId: matrixId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FD),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: "Start new chat"),
            RoomNameInput(controller: roomNameController),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contacts on Zenify",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Expanded(
              child: UserList(
                users: users,
                isLoading: isLoading,
                onUserTap: _handleUserTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
