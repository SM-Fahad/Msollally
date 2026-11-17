import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';

class StudentEditPostScreen extends StatefulWidget {
  final int postId;
  final String initialContent;
  final String? initialMediaUrl;
  final List<String>? initialMediaUrls;
  final bool? initialIsAnnouncement;

  // We accept author info just to show the header properly
  final String authorName;
  final String? authorAvatarUrl;

  const StudentEditPostScreen({
    super.key,
    required this.postId,
    required this.initialContent,
    this.initialMediaUrl,
    this.initialMediaUrls,
    this.initialIsAnnouncement,
    required this.authorName,
    this.authorAvatarUrl,
  });

  @override
  State<StudentEditPostScreen> createState() => _StudentEditPostScreenState();
}

class _StudentEditPostScreenState extends State<StudentEditPostScreen> {
  late TextEditingController _textController;
  late List<String> _existingMediaUrls;
  final List<String> _newLocalImagePaths = [];
  late bool _isAnnouncement;
  final StudentCampusController _campusController =
      Get.find<StudentCampusController>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialContent);
    if (widget.initialMediaUrls != null &&
        widget.initialMediaUrls!.isNotEmpty) {
      _existingMediaUrls = List<String>.from(widget.initialMediaUrls!);
    } else if (widget.initialMediaUrl != null &&
        widget.initialMediaUrl!.isNotEmpty) {
      _existingMediaUrls = [widget.initialMediaUrl!];
    } else {
      _existingMediaUrls = [];
    }
    _isAnnouncement = widget.initialIsAnnouncement ?? false;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final f in pickedFiles) {
            if (!_newLocalImagePaths.contains(f.path)) {
              _newLocalImagePaths.add(f.path);
            }
          }
        });
        return;
      }
    } catch (_) {}

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (!_newLocalImagePaths.contains(pickedFile.path)) {
          _newLocalImagePaths.add(pickedFile.path);
        }
      });
    }
  }

  void _savePost() {
    if (_textController.text.trim().isEmpty &&
        _newLocalImagePaths.isEmpty &&
        _existingMediaUrls.isEmpty) {
      Get.snackbar(
        'Error',
        'Post cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.back();
    _campusController.updatePost(
      widget.postId,
      _textController.text.trim(),
      mediaUrl: _existingMediaUrls.isNotEmpty ? _existingMediaUrls.first : "",
      existingMediaUrls: _existingMediaUrls,
      newImagePaths: _newLocalImagePaths,
      isAnnouncement: _isAnnouncement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Edit Post',
            style: appTextStyleHeading1(
              fontSize: 18.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _savePost,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.width),
              ),
              child: Text(
                'SAVE',
                style: appTextStyleHeading1(
                  fontSize: 15.fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.width),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuthorHeader(),
                    SizedBox(height: 16.height),
                    _buildTextField(),
                    SizedBox(height: 16.height),
                    _buildImagePreview(),
                  ],
                ),
              ),
            ),
            _buildBottomToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        _buildProfileFallback(),
        SizedBox(width: 12.width),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.authorName.isNotEmpty ? widget.authorName : 'Student',
              style: appTextStyleHeading1(
                fontSize: 16.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Icon(Icons.public, size: 14, color: Colors.grey.shade600),
                SizedBox(width: 4.width),
                Text(
                  'Public',
                  style: appTextStyleHeading2(
                    fontSize: 13.fontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileFallback() {
    final avatarUrl =
        widget.authorAvatarUrl ??
        Get.find<StudentProfileController>().profileImageUrl.value;

    return Container(
      height: 48.height,
      width: 48.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.radius),
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, color: Colors.grey.shade400, size: 30),
              )
            : Icon(Icons.person, color: Colors.grey.shade400, size: 30),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _textController,
      autofocus: false,
      maxLines: null,
      minLines: 3,
      keyboardType: TextInputType.multiline,
      style: appTextStyleHeading1(
        fontSize: 18.fontSize,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: "What's on your mind?",
        hintStyle: TextStyle(
          fontSize: 18.fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade400,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_existingMediaUrls.isEmpty && _newLocalImagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._existingMediaUrls.asMap().entries.map((entry) {
          final idx = entry.key;
          final url = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.height),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.radius),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _existingMediaUrls.removeAt(idx);
                      });
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        ..._newLocalImagePaths.asMap().entries.map((entry) {
          final idx = entry.key;
          final path = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.height),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.radius),
                  child: Image.file(
                    File(path),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _newLocalImagePaths.removeAt(idx);
                      });
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 12.height),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Add to your post',
                style: appTextStyleHeading1(
                  fontSize: 15.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: Colors.green, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
