import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/schedule_classes/controller/teacher_schedule_class_controller.dart';
import 'package:msollaally/feature/teacher/schedule_classes/model/class_schedule_model.dart';
import 'package:msollaally/feature/teacher/schedule_classes/service/class_schedule_service.dart';
import 'package:msollaally/feature/student/calender/controller/student_calender_controller.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kPalette = [
  AppColors.primaryButtonColor,
  AppColors.mediumPurple8757F3,
  AppColors.checkBoxActiveColor,
  AppColors.coralFF9244,
  AppColors.royalBlue1565C0,
];

Color _accent(int index, Color eventColor) {
  final plain = [AppColors.primaryButtonColor, AppColors.black000000];
  return plain.contains(eventColor) ? _kPalette[index % _kPalette.length] : eventColor;
}

// ── Top-level time helpers ────────────────────────────────────────────────────
TimeOfDay _toTOD(String hms) {
  final p = hms.split(':');
  return TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0);
}

String _fmtHms(String hms) {
  final t = _toTOD(hms);
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}

String _fmtTOD(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}

String _durationHms(String s, String e) {
  final sp = s.split(':'), ep = e.split(':');
  final diff = ((int.tryParse(ep[0]) ?? 0) * 60 + (int.tryParse(ep[1]) ?? 0))
      - ((int.tryParse(sp[0]) ?? 0) * 60 + (int.tryParse(sp[1]) ?? 0));
  if (diff <= 0) return '';
  return diff < 60 ? '${diff}min' : diff % 60 == 0 ? '${diff ~/ 60}h' : '${diff ~/ 60}h ${diff % 60}min';
}

String _durationDT(DateTime? s, DateTime? e) {
  if (s == null || e == null) return '';
  final diff = e.difference(s).inMinutes;
  if (diff <= 0) return '';
  return diff < 60 ? '${diff}min' : diff % 60 == 0 ? '${diff ~/ 60}h' : '${diff ~/ 60}h ${diff % 60}min';
}

String _fmtDT(DateTime? dt) => dt == null ? '—' : DateFormat('h:mm a').format(dt);
String _apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String _apiTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

// ── Entry point ───────────────────────────────────────────────────────────────

void showEventDetailSheet<T extends Object?>(
  List<CalendarEventData<T>> events,
  DateTime date,
) {
  if (events.isEmpty) return;
  Get.bottomSheet(
    _DetailSheet<T>(events: events, date: date),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
}

// ── Shell (StatelessWidget) ───────────────────────────────────────────────────

class _DetailSheet<T extends Object?> extends StatelessWidget {
  const _DetailSheet({required this.events, required this.date});

  final List<CalendarEventData<T>> events;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: events.length == 1 ? 0.60 : 0.78,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: AppColors.whiteFDFEFF,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(children: [
          // drag handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: AppColors.lightGrayCBD5E1, borderRadius: BorderRadius.circular(99)),
              ),
            ),
          ),
          // header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Row(children: [
              Expanded(
                child: Text(
                  events.length == 1 ? 'Class Details' : '${events.length} Classes',
                  style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              _chip(DateFormat('EEE, MMM d').format(date), AppColors.aliceBlueE8F0FF, AppColors.primaryButtonColor),
            ]),
          ),
          Divider(height: 1, color: AppColors.lavenderE2E8F0),
          Expanded(
            child: ListView.builder(
              controller: sc,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: events.length,
              itemBuilder: (_, i) => _EventCard<T>(event: events[i], index: i),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Event card (StatelessWidget + FutureBuilder) ──────────────────────────────

class _EventCard<T extends Object?> extends StatelessWidget {
  // Future is created once in the constructor so FutureBuilder never re-fetches.
  _EventCard({required this.event, required this.index}) {
    _future = _isApiEvent ? _loadDetails() : null;
  }

  final CalendarEventData<T> event;
  final int index;
  late final Future<(int, ClassScheduleModel)>? _future;

  bool get _isApiEvent => event.event == null;
  Color get _color => _accent(index, event.color);

  Future<(int, ClassScheduleModel)> _loadDetails() async {
    int? id;
    if (Get.isRegistered<TeacherScheduleClassController>()) {
      id = Get.find<TeacherScheduleClassController>()
          .getApiScheduleId(event.title, event.startTime);
    } else if (Get.isRegistered<StudentCalenderController>()) {
      id = Get.find<StudentCalenderController>()
          .getApiScheduleId(event.title, event.startTime);
    }
    if (id == null) throw Exception('Schedule not found. Please refresh.');
    final model = await ClassScheduleService().getScheduleById(id);
    return (id, model);
  }

  // ── Edit and Delete are static — no instance state needed ────────────────────

  static Future<void> _edit(ClassScheduleModel m) async {
    Get.put(_EditCtrl(m));
    final ok = await Get.dialog<bool>(const _EditDialog(), barrierDismissible: false);
    Get.delete<_EditCtrl>();
    if (ok == true) {
      Get.back();
      if (Get.isRegistered<TeacherScheduleClassController>()) {
        Get.find<TeacherScheduleClassController>().loadScheduledClasses();
      } else if (Get.isRegistered<StudentCalenderController>()) {
        Get.find<StudentCalenderController>().loadScheduledClasses();
      }
    }
  }

  static Future<void> _delete(int id, String title) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      title: Text('Delete Class?', style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Text('This action cannot be undone.',
          style: getTextStyle(fontSize: 14, color: AppColors.secondaryTextColor)),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.uiDangerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: () => Get.back(result: true),
          child: Text('Delete', style: getTextStyle(color: AppColors.whiteFDFEFF)),
        ),
      ],
    ));
    if (ok != true) return;

    EasyLoading.show(status: 'Deleting…');
    try {
      await ClassScheduleService().deleteSchedule(id);
      EasyLoading.showSuccess('Deleted successfully');
      Get.back();
      if (Get.isRegistered<TeacherScheduleClassController>()) {
        Get.find<TeacherScheduleClassController>().loadScheduledClasses();
      } else if (Get.isRegistered<StudentCalenderController>()) {
        Get.find<StudentCalenderController>().loadScheduledClasses();
      }
    } catch (e) {
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteFDFEFF,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lavenderE2E8F0),
        boxShadow: [BoxShadow(color: AppColors.black000000.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // banner
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.10),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            border: Border(left: BorderSide(color: c, width: 4)),
          ),
          child: Row(children: [
            Expanded(child: Text(event.title, style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            _chip(_isApiEvent ? 'Scheduled' : 'Course Class', c.withValues(alpha: 0.12), c),
          ]),
        ),
        // body — API events use FutureBuilder; course events render immediately
        if (_isApiEvent)
          FutureBuilder<(int, ClassScheduleModel)>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 28.h),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(c), strokeWidth: 2.5),
                    SizedBox(height: 8.h),
                    Text('Loading…', style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor)),
                  ])),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    snap.error?.toString().replaceFirst('Exception: ', '') ?? 'Failed to load.',
                    style: getTextStyle(fontSize: 13, color: AppColors.uiDangerColor),
                  ),
                );
              }
              final (id, model) = snap.data!;
              return Padding(padding: EdgeInsets.all(16.w), child: _apiBody(model, id, c));
            },
          )
        else
          Padding(padding: EdgeInsets.all(16.w), child: _courseBody(c)),
      ]),
    );
  }

  Widget _apiBody(ClassScheduleModel s, int id, Color c) {
    final dur = _durationHms(s.startTime, s.endTime);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.calendar_today_outlined, size: 14.sp, color: AppColors.secondaryTextColor),
        SizedBox(width: 6.w),
        Text(DateFormat('EEE, MMM d, yyyy').format(s.dateTime),
            style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor, fontWeight: FontWeight.w500)),
      ]),
      SizedBox(height: 12.h),
      Row(children: [
        _timeChip(Icons.access_time_rounded, 'Start', _fmtHms(s.startTime), c),
        SizedBox(width: 8.w),
        _timeChip(Icons.access_time_filled_rounded, 'End', _fmtHms(s.endTime), c),
        if (dur.isNotEmpty) ...[SizedBox(width: 8.w), _durBadge(dur, c)],
      ]),
      if (s.description.trim().isNotEmpty) ...[
        _divider(),
        Text('Description', style: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryTextColor)),
        SizedBox(height: 4.h),
        Text(s.description, style: getTextStyle(fontSize: 14, height: 1.5)),
      ],
      _divider(),
      Row(children: [
        Expanded(child: _actionBtn('Edit', Icons.edit_outlined, c, () => _edit(s))),
        SizedBox(width: 10.w),
        Expanded(child: _actionBtn('Delete', Icons.delete_outline_rounded, AppColors.uiDangerColor,
            () => _delete(id, s.title), isDestructive: true)),
      ]),
    ]);
  }

  Widget _courseBody(Color c) {
    final dur = _durationDT(event.startTime, event.endTime);
    final meta = event.event;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _timeChip(Icons.access_time_rounded, 'Start', _fmtDT(event.startTime), c),
        SizedBox(width: 8.w),
        _timeChip(Icons.access_time_filled_rounded, 'End', _fmtDT(event.endTime), c),
        if (dur.isNotEmpty) ...[SizedBox(width: 8.w), _durBadge(dur, c)],
      ]),
      if ((event.description ?? '').trim().isNotEmpty) ...[
        _divider(),
        Text(event.description!, style: getTextStyle(fontSize: 14, height: 1.5)),
      ],
      if (meta is TeacherCalendarClassEvent) ...[
        _divider(),
        _metaRow(Icons.school_rounded, 'Course', meta.course.title, c),
        SizedBox(height: 8.h),
        _metaRow(Icons.layers_rounded, 'Module', meta.module.title, c),
        if (meta.courseClass.classroom.trim().isNotEmpty &&
            meta.courseClass.classroom.trim().toLowerCase() != 'tba') ...[
          SizedBox(height: 8.h),
          _metaRow(Icons.room_rounded, 'Classroom', meta.courseClass.classroom.trim(), c),
        ],
      ] else if (meta is StudentCalendarClassEvent) ...[
        _divider(),
        _metaRow(Icons.school_rounded, 'Course', meta.courseDetail.title, c),
        SizedBox(height: 8.h),
        _metaRow(Icons.layers_rounded, 'Module', meta.module.title, c),
        if (meta.courseClass.classroom.trim().isNotEmpty &&
            meta.courseClass.classroom.trim().toLowerCase() != 'tba') ...[
          SizedBox(height: 8.h),
          _metaRow(Icons.room_rounded, 'Classroom', meta.courseClass.classroom.trim(), c),
        ],
      ],
    ]);
  }

  // ── micro widgets ─────────────────────────────────────────────────────────────

  Widget _divider() => Column(children: [
    SizedBox(height: 12.h), Divider(height: 1, color: AppColors.lavenderE2E8F0), SizedBox(height: 12.h),
  ]);

  Widget _timeChip(IconData icon, String label, String value, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: c.withValues(alpha: 0.20)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Icon(icon, size: 11.sp, color: c), SizedBox(width: 3.w),
        Text(label, style: getTextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w600)),
      ]),
      SizedBox(height: 2.h),
      Text(value, style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _durBadge(String dur, Color c) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(99)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.timer_outlined, size: 12.sp, color: c), SizedBox(width: 3.w),
      Text(dur, style: getTextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    ]),
  );

  Widget _metaRow(IconData icon, String label, String value, Color c) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(color: c.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, size: 14.sp, color: c),
      ),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: getTextStyle(fontSize: 11, color: AppColors.secondaryTextColor, fontWeight: FontWeight.w500)),
        Text(value, style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ])),
    ],
  );

  Widget _actionBtn(String label, IconData icon, Color c, VoidCallback onTap,
      {bool isDestructive = false}) =>
    OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: isDestructive ? AppColors.tomatoEB5757 : c),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        padding: EdgeInsets.symmetric(vertical: 11.h),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 15.sp),
      label: Text(label, style: getTextStyle(fontWeight: FontWeight.w600, color: c)),
    );
}

// ── Edit GetX controller (not a widget) ───────────────────────────────────────

class _EditCtrl extends GetxController {
  _EditCtrl(this.schedule) {
    titleCtrl = TextEditingController(text: schedule.title);
    descCtrl = TextEditingController(text: schedule.description);
    date = schedule.dateTime.obs;
    start = _toTOD(schedule.startTime).obs;
    end = _toTOD(schedule.endTime).obs;
  }

  final ClassScheduleModel schedule;
  late final TextEditingController titleCtrl;
  late final TextEditingController descCtrl;
  late final Rx<DateTime> date;
  late final Rx<TimeOfDay> start;
  late final Rx<TimeOfDay> end;
  final busy = false.obs;

  @override
  void onClose() { titleCtrl.dispose(); descCtrl.dispose(); super.onClose(); }
}

// ── Edit dialog (GetView extends StatelessWidget) ─────────────────────────────

class _EditDialog extends GetView<_EditCtrl> {
  const _EditDialog();

  Future<void> _save() async {
    if (controller.titleCtrl.text.trim().isEmpty || controller.descCtrl.text.trim().isEmpty) {
      EasyLoading.showError('Please fill in all fields.');
      return;
    }
    controller.busy.value = true;
    try {
      await ClassScheduleService().updateSchedule(
        id: controller.schedule.id,
        title: controller.titleCtrl.text.trim(),
        description: controller.descCtrl.text.trim(),
        date: _apiDate(controller.date.value),
        startTime: _apiTime(controller.start.value),
        endTime: _apiTime(controller.end.value),
      );
      EasyLoading.showSuccess('Updated successfully');
      Get.back(result: true);
    } catch (e) {
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
      controller.busy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Dialog(
      backgroundColor: AppColors.whiteFDFEFF,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit Event', style: getTextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 20.h),
          _field(controller.titleCtrl, 'Title'),
          SizedBox(height: 10.h),
          _field(controller.descCtrl, 'Description', maxLines: 2),
          SizedBox(height: 14.h),
          _picker(Icons.calendar_today_outlined, 'Date',
              DateFormat('EEE, MMM d, yyyy').format(controller.date.value), () async {
            final d = await showDatePicker(context: context,
                initialDate: controller.date.value, firstDate: DateTime(2020), lastDate: DateTime(2035));
            if (d != null) controller.date.value = d;
          }),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _picker(Icons.access_time, 'Start', _fmtTOD(controller.start.value), () async {
              final t = await showTimePicker(context: context, initialTime: controller.start.value);
              if (t != null) controller.start.value = t;
            })),
            SizedBox(width: 10.w),
            Expanded(child: _picker(Icons.access_time_filled, 'End', _fmtTOD(controller.end.value), () async {
              final t = await showTimePicker(context: context, initialTime: controller.end.value);
              if (t != null) controller.end.value = t;
            })),
          ]),
          SizedBox(height: 20.h),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: controller.busy.value ? null : () => Get.back(),
              child: Text('Cancel', style: getTextStyle(color: AppColors.secondaryTextColor)),
            ),
            SizedBox(width: 8.w),
            controller.busy.value
              ? const SizedBox(width: 80, height: 36,
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  onPressed: _save,
                  child: Text('Save', style: getTextStyle(color: AppColors.whiteFDFEFF)),
                ),
          ]),
        ]),
      ),
    ));
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) => TextField(
    controller: ctrl, maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.lightGrayCBD5E1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.lightGrayCBD5E1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColors.primaryButtonColor)),
    ),
  );

  Widget _picker(IconData icon, String label, String value, VoidCallback onTap) => InkWell(
    onTap: controller.busy.value ? null : onTap,
    borderRadius: BorderRadius.circular(10.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrayCBD5E1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(children: [
        Icon(icon, size: 17.sp, color: AppColors.primaryButtonColor),
        SizedBox(width: 8.w),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: getTextStyle(fontSize: 11, color: AppColors.secondaryTextColor)),
          Text(value, style: getTextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
        const Spacer(),
        Icon(Icons.chevron_right, size: 17.sp, color: AppColors.secondaryTextColor),
      ]),
    ),
  );
}

// ── Chip helper ───────────────────────────────────────────────────────────────

Widget _chip(String text, Color bg, Color fg) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
  child: Text(text, style: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
);
