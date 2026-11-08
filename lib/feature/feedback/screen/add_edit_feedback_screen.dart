import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/feedback/controller/feedback_controller.dart';
import 'package:msollaally/feature/feedback/model/feedback_model.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/utils/responsive.dart';

class AddEditFeedbackScreen extends StatefulWidget {
  final FeedbackModel? feedback;

  const AddEditFeedbackScreen({super.key, this.feedback});

  @override
  State<AddEditFeedbackScreen> createState() => _AddEditFeedbackScreenState();
}

class _AddEditFeedbackScreenState extends State<AddEditFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'bug';
  
  final FeedbackController _controller = Get.find<FeedbackController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.clearAttachment();
      if (widget.feedback != null) {
        if (widget.feedback!.attachmentUrl != null && widget.feedback!.attachmentUrl!.isNotEmpty) {
          _controller.uploadedAttachmentUrl.value = widget.feedback!.attachmentUrl;
        }
      }
    });

    if (widget.feedback != null) {
      _titleController.text = widget.feedback!.title ?? '';
      _descController.text = widget.feedback!.description ?? '';
      if (_controller.createCategories.contains(widget.feedback!.category)) {
        _selectedCategory = widget.feedback!.category!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.feedback == null) {
        _controller.createFeedback(
          title: _titleController.text,
          description: _descController.text,
          category: _selectedCategory,
        );
      } else {
        _controller.updateFeedback(
          id: widget.feedback!.id!,
          title: _titleController.text,
          description: _descController.text,
          category: _selectedCategory,
        );
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.height),
      child: Text(
        text,
        style: appTextStyleHeading1(fontSize: 14.fontSize, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildUploadArea() {
    return Obx(() {
      final pickedFile = _controller.pickedFileName.value;
      final existingUrl = _controller.uploadedAttachmentUrl.value;
      final hasFile = pickedFile != null || (existingUrl != null && existingUrl.isNotEmpty);
      
      return GestureDetector(
        onTap: _controller.pickAttachment,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.height, horizontal: 16.width),
          decoration: BoxDecoration(
            color: hasFile ? AppColors.primaryButtonColor.withAlpha((255*0.04).toInt()) : Colors.white,
            border: Border.all(
              color: hasFile ? AppColors.primaryButtonColor.withAlpha((255*0.5).toInt()) : AppColors.lavenderE6EBF2,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12.radius),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.width),
                decoration: BoxDecoration(
                  color: hasFile ? AppColors.primaryButtonColor.withAlpha((255*0.1).toInt()) : AppColors.ghostWhiteF5F7FB,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                  size: 28.width,
                  color: hasFile ? AppColors.primaryButtonColor : Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 16.height),
              Text(
                hasFile ? "Attachment Selected" : "Upload Image or Document",
                style: appTextStyleHeading1(
                  fontSize: 14.fontSize,
                  fontWeight: FontWeight.bold,
                  color: hasFile ? AppColors.primaryButtonColor : Colors.black87,
                ),
              ),
              SizedBox(height: 6.height),
              if (pickedFile != null) ...[
                Text(
                  pickedFile,
                  style: getTextStyle(fontSize: 13.fontSize, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else if (existingUrl != null && existingUrl.isNotEmpty) ...[
                 Text(
                  "Existing attachment is ready",
                  style: appTextStyleHeading1(fontSize: 13.fontSize, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  "Supports JPG, PNG, PDF, DOC",
                  style: appTextStyleHeading1(fontSize: 12.fontSize, color: Colors.grey.shade500),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.feedback != null;

    return Scaffold(
      backgroundColor: AppColors.ghostWhiteF5F7FB,
      appBar: GlobalAppBar(
        title: isEdit ? 'Edit Feedback' : 'Send Feedback',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.width),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Category"),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                items: _controller.createCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.capitalizeFirst ?? c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide(color: AppColors.primaryButtonColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
                ),
              ),
              SizedBox(height: 20.height),
              
              _buildLabel("Title"),
              TextFormField(
                controller: _titleController,
                style: getTextStyle(fontSize: 14.fontSize),
                decoration: InputDecoration(
                  hintText: "Enter a brief title",
                  hintStyle: getTextStyle(fontSize: 14.fontSize, color: Colors.grey.shade400),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide(color: AppColors.primaryButtonColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 20.height),

              _buildLabel("Description"),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                style: getTextStyle(fontSize: 14.fontSize),
                decoration: InputDecoration(
                  hintText: "Please describe your feedback in detail...",
                  hintStyle: getTextStyle(fontSize: 14.fontSize, color: Colors.grey.shade400),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.radius),
                    borderSide: BorderSide(color: AppColors.primaryButtonColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a description' : null,
              ),
              SizedBox(height: 20.height),

              _buildLabel("Attachment (Optional)"),
              _buildUploadArea(),
              SizedBox(height: 40.height),

              SizedBox(
                width: double.infinity,
                height: 52.height,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.radius)),
                  ),
                  child: Text(
                    isEdit ? "Update Feedback" : "Submit Feedback",
                    style: appTextStyleHeading1(fontSize: 16.fontSize, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20.height),
            ],
          ),
        ),
      ),
    );
  }
}
