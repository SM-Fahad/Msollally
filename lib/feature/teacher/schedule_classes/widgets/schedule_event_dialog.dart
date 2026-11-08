import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/schedule_classes/controller/teacher_schedule_class_controller.dart';
import 'package:msollaally/feature/teacher/schedule_classes/service/class_schedule_service.dart';
import 'package:msollaally/feature/student/calender/controller/student_calender_controller.dart';
export 'package:msollaally/feature/teacher/schedule_classes/controller/teacher_schedule_class_controller.dart'
    show TeacherCalendarClassEvent;

// ──────────────────────────────────────────────────────────────────────────────
// Entry point — keeps the original call-site signature unchanged.
// ──────────────────────────────────────────────────────────────────────────────

void showAddEventDialog<T extends Object?>(
    EventController<T> controller) {
  Get.dialog(
    _AddEventDialog<T>(eventController: controller),
    barrierDismissible: false,
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// StatefulWidget so selected date & time update live inside the dialog.
// ──────────────────────────────────────────────────────────────────────────────

class _AddEventDialog<T extends Object?> extends StatefulWidget {
  const _AddEventDialog({super.key, required this.eventController});

  final EventController<T> eventController;

  @override
  State<_AddEventDialog<T>> createState() => _AddEventDialogState<T>();
}

class _AddEventDialogState<T extends Object?> extends State<_AddEventDialog<T>> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  bool _isSubmitting = false;
  String? _errorText;

  // ── helpers ──────────────────────────────────────────────────────────────────

  String get _formattedDate =>
      DateFormat('EEE, MMM d, yyyy').format(_selectedDate);

  String _formatTime(TimeOfDay t) {
    final minute = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '${hour12.toString().padLeft(2, '0')}:$minute $ampm';
  }

  String _toApiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  String _toApiTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  // ── pickers ───────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  // ── submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      // 1) POST to the API
      final schedule = await ClassScheduleService().createSchedule(
        title: title,
        description: desc,
        date: _toApiDate(_selectedDate),
        startTime: _toApiTime(_startTime),
        endTime: _toApiTime(_endTime),
      );

      // 2) Add to local calendar_view
      final startDT = schedule.startDateTime;
      final endDT = schedule.endDateTime;

      widget.eventController.add(
        CalendarEventData<T>(
          title: schedule.title,
          description: schedule.description,
          date: startDT,
          startTime: startDT,
          endTime: endDT,
        ),
      );

      // 3) Refresh the full list so everything stays in sync
      if (Get.isRegistered<TeacherScheduleClassController>()) {
        Get.find<TeacherScheduleClassController>().loadScheduledClasses();
      } else if (Get.isRegistered<StudentCalenderController>()) {
        Get.find<StudentCalenderController>().loadScheduledClasses();
      }

      Get.back();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title
            Text(
              Get.isRegistered<StudentCalenderController>()
                  ? 'Create a Calender event'
                  : 'Add Event',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // ── Fields
            _buildTextField(_titleController, 'Title'),
            const SizedBox(height: 10),
            _buildTextField(_descController, 'Description', maxLines: 2),
            const SizedBox(height: 16),

            // ── Date picker row
            _PickerRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _formattedDate,
              onTap: _isSubmitting ? null : _pickDate,
            ),
            const SizedBox(height: 10),

            // ── Time pickers
            Row(
              children: [
                Expanded(
                  child: _PickerRow(
                    icon: Icons.access_time,
                    label: 'Start',
                    value: _formatTime(_startTime),
                    onTap: _isSubmitting ? null : _pickStartTime,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerRow(
                    icon: Icons.access_time_filled,
                    label: 'End',
                    value: _formatTime(_endTime),
                    onTap: _isSubmitting ? null : _pickEndTime,
                  ),
                ),
              ],
            ),

            // ── Error
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: getTextStyle(
                  fontSize: 13,
                  color: Colors.red.shade600,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : Get.back,
                  child: Text(
                    'Cancel',
                    style: getTextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 80,
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          'Add',
                          style: getTextStyle(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tappable picker row — shows label + selected value.
// ──────────────────────────────────────────────────────────────────────────────

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: getTextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}
