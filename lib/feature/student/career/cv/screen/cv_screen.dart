import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';

import '../controller/cv_controller.dart';
import '../widgets/cv_date_field.dart';
import '../widgets/cv_input_field.dart';
import '../widgets/cv_phone_field.dart';

class CvScreen extends StatelessWidget {
  CvScreen({super.key});

  final CvController controller = Get.put(CvController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.editingCvId.value != null ? "Edit CV" : "Customize CV",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Personal Details'),
            const SizedBox(height: 20),
            CvInputField(
              label: 'First Name',
              hintText: 'Enter first name',
              controller: controller.personalControllers['firstName'],
            ),
            CvInputField(
              label: 'Middle Name',
              hintText: 'Enter middle name',
              controller: controller.personalControllers['middleName'],
            ),
            CvInputField(
              label: 'Last Name',
              hintText: 'Enter last name',
              controller: controller.personalControllers['lastName'],
            ),
            CvDateField(
              label: 'Date of Birth',
              dateKey: 'dob',
              controller: controller,
            ),
            _dropdownField(
              label: 'Sex',
              value: controller.selectedSex,
              items: const ['male', 'female'],
            ),
            _dropdownField(
              label: 'Marital Status',
              value: controller.selectedMaritalStatus,
              items: const ['single', 'married', 'divorced', 'widowed'],
            ),
            CvInputField(
              label: 'Other Marital Status',
              hintText: 'e.g. In a relationship (optional)',
              controller: controller.otherMaritalStatusController,
            ),
            CvInputField(
              label: 'Nationality',
              hintText: 'Enter nationality',
              controller: controller.personalControllers['nationality'],
            ),
            CvInputField(
              label: 'Language Proficiency',
              hintText: 'English, Swahili',
              controller: controller.personalControllers['languageProficiency'],
            ),
            CvInputField(
              label: 'Contact Address',
              hintText: 'Enter contact address',
              controller: controller.personalControllers['contactAddress'],
              maxLines: 2,
            ),
            CvPhoneField(label: 'Phone', controller: controller),
            CvInputField(
              label: 'Email',
              hintText: 'Enter email',
              controller: controller.personalControllers['email'],
              keyboardType: TextInputType.emailAddress,
            ),
            CvInputField(
              label: 'Personal Summary',
              hintText: 'Write a short professional summary',
              controller: controller.personalControllers['personalSummery'],
              maxLines: 5,
            ),
            CvInputField(
              label: 'Hobbies',
              hintText: 'Watching Series, Thinking about her',
              controller: controller.personalControllers['hobbies'],
            ),
            _educationSection(),
            _experienceSection(),
            _referrerSection(),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => _showCvPreview(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryButtonColor,
                side: const BorderSide(color: AppColors.primaryButtonColor, width: 1.5),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.remove_red_eye_outlined),
              label: const Text('Preview CV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: controller.editingCvId.value != null
                          ? "Update CV"
                          : "Create",
                      onPressed: controller.editingCvId.value != null
                          ? controller.updateCv
                          : controller.createCv,
                    ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showCvPreview(BuildContext context) {
    final firstName = controller.personalControllers['firstName']?.text ?? '';
    final lastName = controller.personalControllers['lastName']?.text ?? '';
    final email = controller.personalControllers['email']?.text ?? '';
    final phone = controller.phoneValue.value.isNotEmpty
        ? controller.phoneValue.value
        : controller.phoneController.text;
    final nationality = controller.personalControllers['nationality']?.text ?? '';
    final sex = controller.selectedSex.value;
    final summary = controller.personalControllers['personalSummery']?.text ?? '';
    final hobbies = controller.personalControllers['hobbies']?.text ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CV Preview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '$firstName $lastName'.trim().isEmpty
                        ? 'Unnamed Candidate'
                        : '$firstName $lastName'.trim(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (email.isNotEmpty || phone.isNotEmpty)
                    Text(
                      [if (email.isNotEmpty) email, if (phone.isNotEmpty) phone].join(' • '),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  if (nationality.isNotEmpty || sex.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Sex: ${sex.capitalizeFirst} • Nationality: $nationality',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Professional Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(summary, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                  if (controller.educations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Education', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    ...controller.educations.map((edu) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${edu.degree.text} at ${edu.institution.text}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )),
                  ],
                  if (controller.experiences.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    ...controller.experiences.map((exp) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${exp.position.text} at ${exp.companyName.text}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )),
                  ],
                  if (hobbies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Hobbies & Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(hobbies, style: const TextStyle(fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    text: controller.editingCvId.value != null ? 'Submit Update' : 'Submit & Create CV',
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (controller.editingCvId.value != null) {
                        controller.updateCv();
                      } else {
                        controller.createCv();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _educationSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title: 'Education', onAdd: controller.addEducation),
          ...controller.educations.asMap().entries.map((entry) {
            final index = entry.key;
            final education = entry.value;
            return _group(
              title: 'Education ${index + 1}',
              canRemove: controller.educations.length > 1,
              onRemove: () => controller.removeEducation(index),
              children: [
                CvInputField(
                  label: 'Institution',
                  hintText: 'Enter institution',
                  controller: education.institution,
                ),
                CvInputField(
                  label: 'Degree',
                  hintText: 'Enter degree',
                  controller: education.degree,
                ),
                CvDateField(
                  label: 'Start Date',
                  controller: controller,
                  textController: education.startDate,
                  dateKey: 'education_${index}_start',
                ),
                CvDateField(
                  label: 'End Date',
                  controller: controller,
                  textController: education.endDate,
                  dateKey: 'education_${index}_end',
                ),
                CvInputField(
                  label: 'GPA',
                  hintText: 'Enter GPA',
                  controller: education.gpa,
                  keyboardType: TextInputType.number,
                ),
                CvInputField(
                  label: 'Description',
                  hintText: 'Enter education details',
                  controller: education.description,
                  maxLines: 3,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _experienceSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title: 'Experience', onAdd: controller.addExperience),
          ...controller.experiences.asMap().entries.map((entry) {
            final index = entry.key;
            final experience = entry.value;
            return _group(
              title: 'Experience ${index + 1}',
              canRemove: controller.experiences.length > 1,
              onRemove: () => controller.removeExperience(index),
              children: [
                CvInputField(
                  label: 'Company Name',
                  hintText: 'Enter company name',
                  controller: experience.companyName,
                ),
                CvInputField(
                  label: 'Position',
                  hintText: 'Enter position',
                  controller: experience.position,
                ),
                CvDateField(
                  label: 'Start Date',
                  controller: controller,
                  textController: experience.startDate,
                  dateKey: 'experience_${index}_start',
                ),
                CvDateField(
                  label: 'End Date',
                  controller: controller,
                  textController: experience.endDate,
                  dateKey: 'experience_${index}_end',
                ),
                CvInputField(
                  label: 'Description',
                  hintText: 'Enter work details',
                  controller: experience.description,
                  maxLines: 3,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _referrerSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(title: 'Referrers', onAdd: controller.addReferrer),
          ...controller.referrers.asMap().entries.map((entry) {
            final index = entry.key;
            final referrer = entry.value;
            return _group(
              title: 'Referrer ${index + 1}',
              canRemove: controller.referrers.length > 1,
              onRemove: () => controller.removeReferrer(index),
              children: [
                CvInputField(
                  label: 'Name',
                  hintText: 'Enter referrer name',
                  controller: referrer.name,
                ),
                CvInputField(
                  label: 'Role',
                  hintText: 'Enter role',
                  controller: referrer.role,
                ),
                CvInputField(
                  label: 'Organization',
                  hintText: 'Enter organization',
                  controller: referrer.organization,
                ),
                CvInputField(
                  label: 'Address 1',
                  hintText: 'Enter address line 1',
                  controller: referrer.address1,
                ),
                CvInputField(
                  label: 'Address 2',
                  hintText: 'Enter address line 2',
                  controller: referrer.address2,
                ),
                CvInputField(
                  label: 'Phone',
                  hintText: 'Enter phone',
                  controller: referrer.phone,
                  keyboardType: TextInputType.phone,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, required VoidCallback onAdd}) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        children: [
          Expanded(child: _sectionTitle(title)),
          IconButton(
            onPressed: onAdd,
            icon: Icon(Icons.add_circle_outline),
            tooltip: 'Add $title',
          ),
        ],
      ),
    );
  }

  Widget _group({
    required String title,
    required List<Widget> children,
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.remove_circle_outline),
                  tooltip: 'Remove $title',
                ),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required RxString value,
    required List<String> items,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          SizedBox(height: 4),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: value.value,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item.capitalizeFirst ?? item),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) value.value = newValue;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.dodgerBlueAlpha08418AFF,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  TextStyle get _labelStyle {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Color.fromARGB(255, 109, 112, 114),
    );
  }
}
