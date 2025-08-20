import 'package:flutter/material.dart';

// Renamed the custom widget to avoid conflict with Flutter's built-in TextField
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.scan,
    required this.label,
    this.controller, // Added a TextEditingController parameter
  });

  final dynamic scan;
  final String label;
  final TextEditingController? controller; // Optional TextEditingController

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.5),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 14),
              textScaleFactor: 1.0,
            ),
          ),
          // const SizedBox(height: 5), // Uncommented to add spacing
          TextFormField(
            controller: widget.controller, // Use the passed controller
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0, // Border color and width when not focused
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 123, 125, 126),
                  width: 1.0, // Border color and width when focused
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(5, 12.5, 0, 0),
              hintStyle: TextStyle(
                fontSize: 14.0, // Placeholder font size
                color: Colors.grey,
                // Placeholder text color
              ),
              // hintText: 'Upload Images',
            ),
          ),
        ],
      ),
    );
  }
}
