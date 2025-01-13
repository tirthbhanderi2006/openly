import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String bioText;
  const BioBox({super.key,required this.bioText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary
      ),
      child: Text(bioText.isEmpty?'Empty Bio':bioText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary
      ),),
    );
  }
}
