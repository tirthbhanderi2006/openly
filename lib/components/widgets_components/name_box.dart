import 'package:flutter/material.dart';

class NameBox extends StatelessWidget {
  final String nameText;
  const NameBox({super.key,required this.nameText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.secondary
      ),
      child: Text(AutofillHints.name.isEmpty?'Empty Bio':nameText,
        style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary
        ),),
    );
  }
}
