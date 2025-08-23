import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerField extends StatefulWidget {
  const CustomDatePickerField({
    Key? key,
    required this.label,
    this.controller,
    this.star = false,
  }) : super(key: key);

  final String label;
  final TextEditingController? controller;
  final bool star; // to match CustomTextField style

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  DateTime? _selectedDate;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = picked;
  //       widget.controller?.text = DateFormat("yyyy-MM-dd").format(picked);
  //     });
  //   }
  // }
Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Header & active day color
              onPrimary: Colors.white, // Text color on header
              onSurface: Colors.black, // Text color for days
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        widget.controller?.text = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + optional star
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(221, 58, 58, 59),
                ),
              ),
              const SizedBox(width: 5),
              if (widget.star)
                const Text(
                  "*",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(221, 255, 0, 0),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // DatePicker styled like CustomTextField
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SizedBox(
            height: 43,
            child: TextField(
              controller: widget.controller,
              readOnly: true, // prevent manual typing
              onTap: () => _selectDate(context),
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month,
                    color: Colors.grey,
                    size: 28,
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

