import 'package:flutter/material.dart';

class CustomTimeFieldDialog extends StatelessWidget {
  const CustomTimeFieldDialog({
    super.key,
    required this.label,
    required this.controller,
    required this.star,
    required this.isMissingFieldNotifier,
    this.icon,
    this.onclickIcon,
    this.focusNode,
    this.initialTime,
  });

  final String label;
  final bool star;
  final TextEditingController controller;
  final ValueNotifier<Map<String, dynamic>> isMissingFieldNotifier;
  final Widget? icon;
  final VoidCallback? onclickIcon;
  final FocusNode? focusNode;
  final TimeOfDay? initialTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? now,
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: isMissingFieldNotifier,
      builder: (context, fieldState, _) {
        bool isMissing =
            fieldState["missing"] == true && fieldState["isAdded"] == 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize:  MediaQuery.of(context).size.width * 0.032,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(221, 58, 58, 59),
                  ),
                ),
                if (star)
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
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: TextField(
                
                focusNode: focusNode,
                controller: controller,
                readOnly: true,
                onTap: () => _selectTime(context),
                style:  TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 7,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: isMissing
                          ? Colors.red
                          : const Color.fromARGB(255, 206, 206, 208),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: isMissing
                          ? Colors.red
                          : const Color.fromARGB(255, 203, 203, 203),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: isMissing
                          ? Colors.red
                          : const Color.fromARGB(255, 96, 126, 105),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: icon != null
                      ? GestureDetector(
                          onTap: onclickIcon,
                          child: icon,
                        )
                      : const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 126, 126, 129),
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
