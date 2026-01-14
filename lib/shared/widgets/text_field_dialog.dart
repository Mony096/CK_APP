import 'package:flutter/material.dart';

class CustomTextFieldDialog extends StatelessWidget {
  const CustomTextFieldDialog({
    super.key,
    required this.label,
    required this.controller,
    required this.star,
    this.isMissingFieldNotifier,
    this.icon,
    this.onclickIcon,
    this.focusNode,
    this.readOnly = false,
    this.disabled = false,
  });

  final String label;
  final bool star;
  final TextEditingController controller;
  final ValueNotifier<Map<String, dynamic>>? isMissingFieldNotifier;
  final Widget? icon;
  final VoidCallback? onclickIcon;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    Widget labelWidget([Map<String, dynamic>? fieldState]) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize:  MediaQuery.of(context).size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(221, 58, 58, 59),
                ),
              ),
              if (star && !disabled)
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    "*",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
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

    final isDisabled = disabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMissingFieldNotifier != null
            ? ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: isMissingFieldNotifier!,
                builder: (context, fieldState, _) {
                  return labelWidget(fieldState);
                },
              )
            : labelWidget(),
        const SizedBox(height: 8),
        SizedBox(
          height: 43,
          child: TextField(
            focusNode: focusNode,
            controller: controller,
            enabled: !isDisabled,
            readOnly: readOnly,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.037,
              color: isDisabled ? Colors.black54 : Colors.black,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: isDisabled
                      ? Colors.grey
                      : const Color.fromARGB(255, 206, 206, 208),
                  width: isDisabled ? 0 : 1, // 👈 smaller border for disabled
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: isDisabled
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 203, 203, 203),
                  width: isDisabled ? 0 : 1, // 👈 smaller border
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(
                  color: isDisabled
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 96, 126, 105),
                  width: isDisabled ? 0 : 1.5, // 👈 smaller border
                ),
              ),
              filled: true,
              fillColor: isDisabled ? Colors.grey[100] : Colors.white,
              suffixIcon: (!isDisabled && icon != null)
                  ? GestureDetector(
                      onTap: onclickIcon,
                      child: icon,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
