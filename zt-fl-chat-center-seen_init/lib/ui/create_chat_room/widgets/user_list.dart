import 'package:flutter/material.dart';
import 'user_list_tile.dart';

class UserList extends StatelessWidget {
  final List<String> users;
  final bool isLoading;
  final void Function(String matrixId) onUserTap;

  const UserList({
    super.key,
    required this.users,
    required this.isLoading,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text("No users found", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        final matrixId = users[index];
        return AnimatedSlide(
          offset: Offset(0, 0.1),
          duration: Duration(milliseconds: 300 + index * 20),
          child: AnimatedOpacity(
            opacity: 1,
            duration: Duration(milliseconds: 300 + index * 20),
            child: UserListTile(
              matrixId: matrixId,
              onTap: () => onUserTap(matrixId),
            ),
          ),
        );
      },
    );
  }
}
