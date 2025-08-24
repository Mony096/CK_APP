import 'package:flutter/material.dart';

class CustomTextFieldDialog extends StatefulWidget {
  const CustomTextFieldDialog({
    super.key,
    this.onclickIcon,
    required this.label,
    required this.controller,
    required this.star,
    this.icon, // optional custom icon widget
    this.focusNode,
  });

  final VoidCallback? onclickIcon;
  final String label;
  final bool star;
  final TextEditingController? controller;
  final Widget? icon; // icon provided by parent
  final dynamic focusNode;

  @override
  State<CustomTextFieldDialog> createState() => _CustomTextFieldDialogState();
}

class _CustomTextFieldDialogState extends State<CustomTextFieldDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Padding(
          // padding: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.only(left: 0),
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

        // TextField with optional parent-provided icon
        Padding(
          // padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          padding: EdgeInsetsGeometry.all(0),
          child: SizedBox(
            height: 43,
            child: TextField(
              //  enabled: false, 
              focusNode: widget.focusNode,
              controller: widget.controller,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
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

                // Use parent-provided icon if it exists
                suffixIcon: widget.icon != null
                    ? GestureDetector(
                        onTap: widget.onclickIcon,
                        child: widget.icon,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
