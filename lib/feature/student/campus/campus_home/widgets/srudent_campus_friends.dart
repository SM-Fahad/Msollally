import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/friends/friends_header.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/friends/friends_tabs.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/friends/friends_list_item.dart';

class StudentCampusFriend extends StatelessWidget {
  const StudentCampusFriend({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentCampusController());
    return Column(
      children: [
        FriendsHeader(controller: controller),
        SizedBox(height: 16.height),
        FriendsTabs(controller: controller),
        SizedBox(height: 12.height),
        _buildFiltersRow(controller),
        SizedBox(height: 16.height),
        Obx(() {
          if (controller.isLoadingFriends.value) {
            return ShimmerLoading.list(
              itemCount: 4,
              height: 72.height,
              borderRadius: 12.radius,
            );
          }

          final selectedTab = controller.selectStudentFriendsTab.value;
          var currentList = controller.friendsForYouList;
          if (selectedTab == 1) {
            currentList = controller.yourCampusList;
          } else if (selectedTab == 2) {
            currentList = controller.requestsList;
          }

          final filteredList = controller.getFilteredFriends(currentList);

          if (filteredList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 32.height),
                child: Text(
                  'No students found matching your criteria',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filteredList.length,
            itemBuilder: (_, index) {
              return FriendsListItem(item: filteredList[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildFiltersRow(StudentCampusController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: Obx(() {
        // Collect unique universities and programs from all friends
        final allFriends = [
          ...controller.friendsForYouList,
          ...controller.yourCampusList,
        ];
        final universities = <String>{'All'};
        final programs = <String>{'All'};
        for (var f in allFriends) {
          if (f.uvName.isNotEmpty && f.uvName != 'N/A') universities.add(f.uvName);
          if (f.program.isNotEmpty) programs.add(f.program);
        }
        final years = ['All', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Postgrad'];

        final isFiltered = controller.selectedUniversityFilter.value != 'All' ||
            controller.selectedProgramFilter.value != 'All' ||
            controller.selectedYearFilter.value != 'All';

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterDropdown(
                label: 'University',
                value: controller.selectedUniversityFilter.value,
                items: universities.toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedUniversityFilter.value = val;
                },
              ),
              SizedBox(width: 8.width),
              _buildFilterDropdown(
                label: 'Program',
                value: controller.selectedProgramFilter.value,
                items: programs.toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedProgramFilter.value = val;
                },
              ),
              SizedBox(width: 8.width),
              _buildFilterDropdown(
                label: 'Year',
                value: controller.selectedYearFilter.value,
                items: years,
                onChanged: (val) {
                  if (val != null) controller.selectedYearFilter.value = val;
                },
              ),
              if (isFiltered) ...[
                SizedBox(width: 8.width),
                InkWell(
                  onTap: () {
                    controller.selectedUniversityFilter.value = 'All';
                    controller.selectedProgramFilter.value = 'All';
                    controller.selectedYearFilter.value = 'All';
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 6.height),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.radius),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 14.fontSize, color: Colors.red),
                        SizedBox(width: 4.width),
                        Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 12.fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value != 'All';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.width, vertical: 2.height),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.radius),
        border: Border.all(
          color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : 'All',
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16.fontSize,
            color: isSelected ? Colors.blue : Colors.grey.shade700,
          ),
          style: TextStyle(
            fontSize: 12.fontSize,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue.shade800 : Colors.black87,
          ),
          isDense: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'All' ? '$label: All' : item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
