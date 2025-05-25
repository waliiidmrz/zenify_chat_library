import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBackButton = true, // Allow toggle if needed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: Colors.white,
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const Icon(Icons.travel_explore, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
