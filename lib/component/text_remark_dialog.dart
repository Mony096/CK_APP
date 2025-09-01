import 'package:flutter/material.dart';

class CustomTextRemarkDialog extends StatefulWidget {
  const CustomTextRemarkDialog({
    super.key,
    required this.label,
    required this.controller,
    required this.star,
    this.isMissingFieldNotifier, // now optional
    this.detail = false,
  });

  final String label;
  final TextEditingController? controller;
  final bool detail;
  final bool star;
  final ValueNotifier<Map<String, dynamic>>? isMissingFieldNotifier; // nullable

  @override
  State<CustomTextRemarkDialog> createState() => _CustomTextRemarkDialogState();
}

class _CustomTextRemarkDialogState extends State<CustomTextRemarkDialog> {
  @override
  Widget build(BuildContext context) {
    final fillColor = widget.detail ? Colors.grey[100] : Colors.white;
    final textColor = widget.detail ? Colors.black : Colors.black87;

    Widget labelRow([Map<String, dynamic>? fieldState]) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          if (fieldState?["missing"] == true && fieldState?["isAdded"] == 1)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                fieldState?["value"] ?? "",
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.isMissingFieldNotifier != null
            ? ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: widget.isMissingFieldNotifier!,
                builder: (context, fieldState, _) {
                  return labelRow(fieldState);
                },
              )
            : labelRow(),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          style: TextStyle(fontSize: 16, color: textColor),
          maxLines: 5,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          enabled: !widget.detail,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(
                color: widget.detail
                    ? Colors.grey[50]!
                    : const Color.fromARGB(255, 206, 206, 208),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(
                color: widget.detail
                    ? Colors.grey[50]!
                    : const Color.fromARGB(255, 203, 203, 203),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(
                color: widget.detail
                    ? Colors.grey[50]!
                    : const Color.fromARGB(255, 96, 126, 105),
                width: widget.detail ? 1 : 1.5,
              ),
            ),
            filled: true,
            fillColor: fillColor,
          ),
        ),
      ],
    );
  }
}
