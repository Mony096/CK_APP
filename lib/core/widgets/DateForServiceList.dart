import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 52,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded,
                color: Color(0xFF64748B), size: 18),
            onPressed: () => _selectDate(context),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                _selectedDate != null
                    ? DateFormat("dd MMMM yyyy").format(_selectedDate!)
                    : "Document Date",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _selectedDate != null
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF94A3B8),
                  fontWeight:
                      _selectedDate != null ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF94A3B8), size: 24),
            onPressed: () => _changeDate(-1),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8), size: 24),
            onPressed: () => _changeDate(1),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
