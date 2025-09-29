import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateForServiceList extends StatefulWidget {
  const DateForServiceList({
    super.key,
    this.controller,
    this.star = false,
    this.detail = false,
  });

  final TextEditingController? controller;
  final bool star;
  final bool detail;

  @override
  State<DateForServiceList> createState() => _DateForServiceListState();
}

class _DateForServiceListState extends State<DateForServiceList> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Listen to controller changes
    widget.controller?.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant DateForServiceList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      widget.controller?.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    // If controller is cleared, reset _selectedDate
    if (widget.controller!.text.isEmpty && _selectedDate != null) {
      setState(() {
        _selectedDate = null;
      });
    }
  }

  // ... keep _selectDate and _changeDate as before ...
  Future<void> _selectDate(BuildContext context) async {
    if (widget.detail) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        widget.controller?.text = DateFormat("dd MMMM yyyy").format(picked);
      });
    }
  }

  void _changeDate(int days) {
    if (_selectedDate == null) return;
    setState(() {
      _selectedDate = _selectedDate!.add(Duration(days: days));
      widget.controller?.text =
          DateFormat("dd MMMM yyyy").format(_selectedDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.detail ? Colors.black : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
      // width: double.infinity,
      height: 48,
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.calendar_month, color: Color.fromARGB(255, 104, 101, 101), size: 28),
            onPressed: () => _selectDate(context),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                _selectedDate != null
                    ? DateFormat("dd MMMM yyyy").format(_selectedDate!)
                    : "Document Date",
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.034, color: textColor),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_left, color: Color.fromARGB(255, 130, 131, 130), size: 28),
            onPressed: () => _changeDate(-1),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_right, color: Color.fromARGB(255, 130, 131, 130), size: 28),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }
}
