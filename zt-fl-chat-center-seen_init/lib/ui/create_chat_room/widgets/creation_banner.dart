import 'package:flutter/material.dart';

class CreationBanner extends StatelessWidget {
  final String message;
  final Color color;

  const CreationBanner({super.key, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
