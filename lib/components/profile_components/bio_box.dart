import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

class BioBox extends StatelessWidget {
  final String bioText;

  const BioBox({super.key, required this.bioText});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            FlutterRemix.sticky_note_line,
            color: isDarkMode ? Colors.white70 : Colors.black54,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              bioText.isEmpty ? 'No bio available' : bioText,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
