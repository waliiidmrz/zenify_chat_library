import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final String matrixId;
  final VoidCallback onTap;

  const UserListTile({
    super.key,
    required this.matrixId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = matrixId.split(":")[0].substring(1);
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 24,
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          title: Text(
            displayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.blueAccent, size: 18),
        ),
      ),
    );
  }
}
