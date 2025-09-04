import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerFieldDialog extends StatefulWidget {
  const CustomDatePickerFieldDialog({
    super.key,
    required this.label,
    this.controller,
    this.star = false,
    this.detail = false, // detail mode
  });

  final String label;
  final TextEditingController? controller;
  final bool star;
  final bool detail;

  @override
  State<CustomDatePickerFieldDialog> createState() =>
      _CustomDatePickerFieldDialogState();
}

class _CustomDatePickerFieldDialogState
    extends State<CustomDatePickerFieldDialog> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    if (widget.detail) return; // disable picker in detail mode

    DateTime tempDate = _selectedDate ?? DateTime.now();

await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 280,
            height: 420,
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🌿 Apply green theme
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.green, // active date color
                      onPrimary: Colors.white, // text color on selected date
                      onSurface: Colors.black87, // default text color
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    onDateChanged: (picked) {
                      tempDate = picked;
                    },
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempDate;
                          widget.controller?.text =
                              DateFormat("yyyy-MM-dd").format(tempDate);
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final textColor = widget.detail ? Colors.black : Colors.black87;
    final fillColor = widget.detail ? Colors.grey[100] : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + optional star
        Row(
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
            if (widget.star && !widget.detail)
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

        const SizedBox(height: 8),

        // TextField
        SizedBox(
          height: 43,
          child: TextField(
            controller: widget.controller,
            readOnly: true,
            onTap: () => _selectDate(context),
            style: TextStyle(fontSize: 16, color: textColor),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              border: widget.detail
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 0.5,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 203, 203, 203),
                        width: 0.5,
                      ),
                    ),
              enabledBorder: widget.detail
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 203, 203, 203),
                        width: 0.5,
                      ),
                    ),
              focusedBorder: widget.detail
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    )
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 96, 126, 105),
                        width: 0.5,
                      ),
                    ),
              filled: true,
              fillColor: fillColor,
              suffixIcon: widget.detail
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.calendar_month,
                        color: Colors.grey,
                        size: 28,
                      ),
                      onPressed: () => _selectDate(context),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
