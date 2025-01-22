import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String bioText;
  const BioBox({super.key, required this.bioText});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary, // Adjust based on theme
      ),
      child: Text(
        bioText.isEmpty ? 'Empty Bio' : bioText,
        style: TextStyle(
          color: isDarkMode
              ? Theme.of(context).colorScheme.onSecondary // Text color for dark mode
              : Theme.of(context).colorScheme.onPrimary, // Text color for light mode
        ),
      ),
    );
  }
}
