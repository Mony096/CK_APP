import 'package:flutter/material.dart';

class CustomTextRemark extends StatefulWidget {
  const CustomTextRemark({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController? controller;

  @override
  State<CustomTextRemark> createState() => _CustomTextRemarkState();
}

class _CustomTextRemarkState extends State<CustomTextRemark> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(221, 58, 58, 59),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Multi-line TextField for remarks
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: TextField(
            controller: widget.controller,
            style: const TextStyle(fontSize: 16),
            maxLines: 5, // Allow multiple lines
            minLines: 3, // Optional: minimum lines
            textInputAction: TextInputAction.newline, // Enter creates new line
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 206, 206, 208),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 203, 203, 203),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 96, 126, 105),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              // hintText: "Enter your remarks here...", // Optional hint
            ),
          ),
        ),
      ],
    );
  }
}
