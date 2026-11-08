import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/teacher/courses/course_students/controller/course_student_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_group_model.dart';
import 'package:msollaally/feature/teacher/courses/course_students/model/course_student_chat_model.dart';
import 'package:msollaally/feature/teacher/courses/course_students/widget/course_student_chat_tile.dart';
import 'package:msollaally/routes/app_route.dart';

class CourseStudentScreen extends StatelessWidget {
  CourseStudentScreen({super.key}) {
    controller = Get.isRegistered<CourseStudentController>()
        ? Get.find<CourseStudentController>()
        : Get.put(CourseStudentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(Get.arguments);
    });
  }

  late final CourseStudentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.fetchCourseStudents,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  prefixIcon: ImageIcon(
                    AssetImage(IconsPath.searchIcon),
                    color: Colors.blue,
                    size: 15,
                  ),
                  hintText: "Search",
                  hintStyle: getTextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  _buildTab("All", controller.selectedTab.value == 0, () {
                    controller.changeTab(0);
                  }),
                  _buildTab("Students", controller.selectedTab.value == 1, () {
                    controller.changeTab(1);
                  }),
                  _buildTab("My Groups", controller.selectedTab.value == 2, () {
                    controller.changeTab(2);
                  }),
                ],
              ),
            ),

            Obx(() {
              final bool showCreate = controller.selectedTab.value == 2;
              if (!showCreate) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create and manage course groups',
                        style: getTextStyle(
                          fontSize: 13,
                          color: Colors.grey[700]!,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: controller.studentChats.isEmpty
                          ? null
                          : () => _showGroupFormSheet(context),
                      icon: const Icon(Icons.group_add_outlined),
                      label: const Text('New Group'),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            Expanded(
              child: Builder(
                builder: (context) {
                  final selected = controller.selectedTab.value;
                  final chats = controller.filteredChats;

                  if (controller.isLoading.value && chats.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chats.isEmpty) {
                    return Center(
                      child: Text(
                        selected == 2
                            ? 'No groups found for this course'
                            : 'No students found for this course',
                        style: getTextStyle(
                          fontSize: 15,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final CourseStudentChatModel model = chats[index];
                      final CourseGroupModel? group = controller
                          .findGroupByChat(model);
                      return GestureDetector(
                        onTap: () async {
                          var resolvedGroup = group;
                          if (model.isGroup && resolvedGroup != null) {
                            resolvedGroup =
                                await controller.getGroupById(
                                  resolvedGroup.id,
                                ) ??
                                resolvedGroup;
                          }

                          Get.toNamed(
                            AppRoute.teacherChatScreen,
                            arguments: {
                              'chatId': resolvedGroup?.chatId ?? model.chatId,
                              'name': model.name,
                              'reciverId': model.recieverId.toString(),
                              'receiverIds':
                                  resolvedGroup?.memberIds ??
                                  [model.recieverId],
                              'chatName': resolvedGroup?.name ?? model.name,
                              'isGroup': model.isGroup,
                              'groupId': resolvedGroup?.id,
                            },
                          );
                        },
                        child: CourseStudentChatTile(
                          chat: model,
                          trailing: model.isGroup && group != null
                              ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final detailedGroup = await controller
                                          .getGroupById(group.id);
                                      if (detailedGroup != null &&
                                          context.mounted) {
                                        _showGroupFormSheet(
                                          context,
                                          group: detailedGroup,
                                        );
                                      }
                                      return;
                                    }

                                    if (value == 'delete' && context.mounted) {
                                      _showDeleteDialog(context, group);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit Group'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete Group'),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGroupFormSheet(
    BuildContext context, {
    CourseGroupModel? group,
  }) async {
    final nameController = TextEditingController(text: group?.name ?? '');
    final selectedIds = <int>{...(group?.memberIds ?? const <int>[])};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group == null ? 'Create Group' : 'Edit Group',
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          hintText: 'Team A',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Students',
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedIds.length} selected',
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.grey[700]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.studentChats.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final student = controller.studentChats[index];
                            final isSelected = selectedIds.contains(
                              student.recieverId,
                            );
                            return CheckboxListTile(
                              value: isSelected,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                student.name,
                                style: getTextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                student.phoneNumber.isNotEmpty
                                    ? student.phoneNumber
                                    : student.lastMessage,
                                style: getTextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: Colors.blue.withValues(
                                  alpha: 0.12,
                                ),
                                backgroundImage: student.avatar.isNotEmpty
                                    ? NetworkImage(student.avatar)
                                    : null,
                                child: student.avatar.isEmpty
                                    ? Text(
                                        student.initials,
                                        style: getTextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (_) {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedIds.remove(student.recieverId);
                                  } else {
                                    selectedIds.add(student.recieverId);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: controller.isSavingGroup.value
                                ? null
                                : () async {
                                    final groupName = nameController.text
                                        .trim();
                                    if (groupName.isEmpty) {
                                      Get.snackbar(
                                        'Group Name',
                                        'Please enter a group name.',
                                      );
                                      return;
                                    }
                                    if (selectedIds.isEmpty) {
                                      Get.snackbar(
                                        'Members',
                                        'Please select at least one student.',
                                      );
                                      return;
                                    }

                                    final bool isSuccess;
                                    if (group == null) {
                                      isSuccess = await controller.createGroup(
                                        name: groupName,
                                        memberIds: selectedIds.toList(),
                                      );
                                    } else {
                                      isSuccess = await controller.updateGroup(
                                        groupId: group.id,
                                        name: groupName,
                                        memberIds: selectedIds.toList(),
                                      );
                                    }

                                    if (isSuccess && context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                            child: controller.isSavingGroup.value
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    group == null
                                        ? 'Create Group'
                                        : 'Save Changes',
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    CourseGroupModel group,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text('Delete "${group.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.deleteGroup(group.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: getTextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
