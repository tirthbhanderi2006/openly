import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color textColor;

  const MyTextfield({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.focusNode,
    this.hintStyle,
    this.fillColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: textColor), // Set text color dynamically
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.tertiary),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          filled: fillColor != null, // Enable or disable the fill color
          fillColor: fillColor ?? theme.colorScheme.inversePrimary,
          hintText: hintText,
          hintStyle: hintStyle ??
              TextStyle(
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
        ),
      ),
    );
  }
}
