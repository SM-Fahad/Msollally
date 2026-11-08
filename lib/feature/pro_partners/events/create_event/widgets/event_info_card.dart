import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/controller/create_event_controller.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/widgets/add_co_host.dart';
import 'event_upload_widget.dart';

class EventInfoCard extends StatelessWidget {
  final CreateEventController controller;
  const EventInfoCard({super.key, required this.controller});

  List<String> _dropdownValues(List<String> defaults, String selectedValue) {
    final values = <String>[...defaults];
    if (selectedValue.isNotEmpty && !values.contains(selectedValue)) {
      values.add(selectedValue);
    }
    return values;
  }

  Future<void> _pickDateTime(
    BuildContext context,
    bool isStart,
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    if (!context.mounted) return;

    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (isStart) {
      controller.setStartDateTime(pickedDateTime);
    } else {
      controller.setEndDateTime(pickedDateTime);
    }
  }

  Widget _dateTimeField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                      ? 'Select date & time'
                      : DateFormat('MM/dd/yyyy hh:mm a').format(value),
                ),
                Icon(Icons.calendar_today_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Information',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Text(
            'Fill in the details for your event',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.tertiaryTextColor,
            ),
          ),
          SizedBox(height: 12.h),
          EventUploadWidget(controller: controller),
          SizedBox(height: 12.h),
          Text(
            'Event Title',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.titleController,
            decoration: InputDecoration(
              hintText: 'Enter event title',
              filled: true,
              fillColor: Colors.black.withAlpha((0.04 * 255).round()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'Description',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.lavenderE2E8F0,
              ),
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: quill.QuillSimpleToolbar(
                    controller: controller.quillController,
                    config: const quill.QuillSimpleToolbarConfig(
                      showFontFamily: false,
                      showFontSize: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showInlineCode: false,
                      showCodeBlock: false,
                      showQuote: false,
                      showLink: false,
                      showUndo: true,
                      showRedo: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: quill.QuillEditor.basic(
                      controller: controller.quillController,
                      config: const quill.QuillEditorConfig(
                        placeholder:
                            'Tell students what this event is about (supports Bold, Italic, Lists)...',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _dateTimeField(
              context: context,
              label: 'Start Date & Time',
              value: controller.startDateTime.value,
              onTap: () =>
                  _pickDateTime(context, true, controller.startDateTime.value),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => _dateTimeField(
              context: context,
              label: 'End Date & Time',
              value: controller.endDateTime.value,
              onTap: () =>
                  _pickDateTime(context, false, controller.endDateTime.value),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Event Type',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: controller.eventType.value.isEmpty
                      ? null
                      : controller.eventType.value,
                  items: [
                    'Virtual',
                    'In-person',
                    'Hybrid',
                    'Others',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => controller.eventType.value = v ?? '',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: Text('Select event type'),
                ),
                if (controller.eventType.value == 'Others' ||
                    controller.eventType.value == 'Other') ...[
                  SizedBox(height: 12.h),
                  Text(
                    'Other Event Type',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: controller.otherEventTypeController,
                    decoration: InputDecoration(
                      hintText: 'Specify event type',
                      filled: true,
                      fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Location',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.locationController,
            decoration: InputDecoration(
              hintText: 'Add your event location',
              filled: true,
              fillColor: Colors.black.withAlpha((0.04 * 255).round()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'On-Line Event Link (optional)',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.onlineLinkController,
            decoration: InputDecoration(
              hintText: 'https://example.com',
              filled: true,
              fillColor: Colors.black.withAlpha((0.04 * 255).round()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Max Attendees (Optional)',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.maxAttendeesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'e.g. 100',
              filled: true,
              fillColor: Colors.black.withAlpha((0.04 * 255).round()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Tags (Optional)',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.tagInputController,
                  onFieldSubmitted: (_) => controller.addTagFromInput(),
                  decoration: InputDecoration(
                    hintText: 'Type tag (tech, networking...)',
                    filled: true,
                    fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: controller.addTagFromInput,
                child: Icon(Icons.add, size: 16),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Obx(
            () => controller.tags.isEmpty
                ? Text(
                    'No tags added',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => controller.removeTag(tag),
                      );
                    }).toList(),
                  ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Co-hosts',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                onPressed: () =>
                    Get.to(() => AddCoHostScreen(controller: controller)),
                icon: Icon(Icons.person_add_alt_1_outlined),
                label: Text('Add'),
              ),
            ],
          ),
          Obx(
            () => controller.selectedCoHosts.isEmpty
                ? Text(
                    'No co-host selected',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.selectedCoHosts.map((host) {
                      final name = (host['fullName'] ?? '').toString();
                      final id = host['id'] as int;
                      return Chip(
                        label: Text(name.isEmpty ? 'User #$id' : name),
                        onDeleted: () => controller.toggleCoHost(host),
                      );
                    }).toList(),
                  ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest Message Group',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Allow attendees to chat with each other in a group',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.tertiaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.guestGroupEnabled.value,
                  onChanged: (v) => controller.guestGroupEnabled.value = v,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Target Major',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final majorOptions = _dropdownValues([
              'All',
              'Computer Science',
              'Electrical Engineering',
              'Business Administration',
              'Law',
            ], controller.targetMajor.value);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: controller.targetMajor.value.isEmpty
                      ? 'All'
                      : controller.targetMajor.value,
                  items: majorOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => controller.targetMajor.value = v ?? 'All',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  hint: const Text('Select Major'),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Text(
            'Target Year',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final yearOptions = _dropdownValues([
              'All',
              '1',
              '2',
              '3',
              '4',
              '5',
              '6',
              '7',
            ], controller.targetYear.value);

            return DropdownButtonFormField<String>(
              initialValue: controller.targetYear.value.isEmpty
                  ? null
                  : controller.targetYear.value,
              items: yearOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => controller.targetYear.value = v ?? '',
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withAlpha((0.04 * 255).round()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text('Select year'),
            );
          }),
        ],
      ),
    );
  }
}
