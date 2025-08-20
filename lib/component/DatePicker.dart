import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerField extends StatefulWidget {
  const CustomDatePickerField({
    Key? key,
    required this.label,
    this.controller,
  }) : super(key: key);

  final String label;
  final TextEditingController? controller;

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  DateTime _selectedDate = DateTime.now(); // Default to current date

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format the date to "2024-10-31T00:00:00Z"
        // widget.controller?.text = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(picked);
        widget.controller?.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context), // Open date picker only on icon tap
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 170, 167, 167),
                width: 1.3,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(5, 12.5, 0, 0),
            hintStyle: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
