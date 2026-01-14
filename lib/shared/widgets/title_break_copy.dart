import 'package:flutter/material.dart';

class ComponentTitleNoPadding extends StatelessWidget {
  const ComponentTitleNoPadding({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left line
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
        ),

        // Center text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              // fontWeight: FontWeight.w500,
              color: Color.fromARGB(221, 85, 81, 81),
            ),
          ),
        ),

        // Right line
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
