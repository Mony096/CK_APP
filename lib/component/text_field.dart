// import 'package:flutter/material.dart';

// class CustomTextField extends StatefulWidget {
//   CustomTextField(
//       {super.key,
//       this.onclickIcon,
//       required this.label,
//       required this.controller,
//       required this.star,
//       this.icon, // optional custom icon widget
//       this.focusNode,
//       required this.detail});

//   final VoidCallback? onclickIcon;
//   final String label;
//   final bool star;
//   final TextEditingController? controller;
//   final Widget? icon; // icon provided by parent
//   final dynamic focusNode;
//   final bool detail;
//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   @override
//   Widget build(BuildContext context) {
//     print(widget.detail);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label row
//         Padding(
//           padding: const EdgeInsets.only(left: 20),
//           // padding: const EdgeInsets.only(left: 0),
//           child: Row(
//             children: [
//               Text(
//                 widget.label,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Color.fromARGB(221, 58, 58, 59),
//                 ),
//               ),
//               const SizedBox(width: 5),
//               if (widget.star)
//                 const Text(
//                   "*",
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: Color.fromARGB(221, 255, 0, 0),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),

//         // TextField with optional parent-provided icon
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//           // padding: EdgeInsetsGeometry.all(0),
//           child: SizedBox(
//             height: 43,
//             child: TextField(
//               enabled: !widget.detail,
//               focusNode: widget.focusNode,
//               controller: widget.controller,
//               style: const TextStyle(fontSize: 16),
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 4,
//                   horizontal: 12,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(7),
//                   borderSide: const BorderSide(
//                     color: Color.fromARGB(255, 206, 206, 208),
//                     width: 1,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(7),
//                   borderSide: const BorderSide(
//                     color: Color.fromARGB(255, 203, 203, 203),
//                     width: 1,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(7),
//                   borderSide: const BorderSide(
//                     color: Color.fromARGB(255, 96, 126, 105),
//                     width: 1.5,
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,

//                 // Use parent-provided icon if it exists
//                 suffixIcon: widget.icon != null
//                     ? GestureDetector(
//                         onTap: widget.onclickIcon,
//                         child: widget.icon,
//                       )
//                     : null,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.onclickIcon,
    required this.label,
    required this.controller,
    required this.star,
    this.icon, // optional custom icon widget
    this.focusNode,
    required this.detail,
    this.readOnly = false, // 👈 optional readOnly
    this.disabled = false, // 👈 optional disabled
  });

  final VoidCallback? onclickIcon;
  final String label;
  final bool star;
  final TextEditingController? controller;
  final Widget? icon; // icon provided by parent
  final FocusNode? focusNode;
  final bool detail;
  final bool readOnly;
  final bool disabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final borderColor = (widget.detail || widget.disabled)
        ? Colors.grey[200]
        : const Color.fromARGB(255, 203, 203, 203);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
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
              if (widget.star && !widget.detail && !widget.disabled)
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

        // TextField
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SizedBox(
            height: 43,
            child: TextField(
              enabled: !(widget.detail ||
                  widget.disabled), // 👈 disabled if detail OR disabled
              readOnly: widget.readOnly, // 👈 only blocks editing
              focusNode: widget.focusNode,
              controller: widget.controller,
              style: TextStyle(
                fontSize: 16,
                color: (widget.detail || widget.disabled)
                    ? Colors.black54
                    : Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: borderColor!,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    color: widget.detail || widget.disabled
                        ? Colors.grey[200]!
                        : const Color.fromARGB(255, 96, 126, 105),
                    width: 0.5,
                  ),
                ),
                filled: true,
                fillColor: (widget.detail || widget.disabled)
                    ? Colors.grey[100]
                    : Colors.white,

                // Hide icon if disabled or detail
                suffixIcon:
                    (!(widget.detail || widget.disabled) && widget.icon != null)
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
