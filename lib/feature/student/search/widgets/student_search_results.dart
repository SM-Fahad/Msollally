import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/student_search_controller.dart';

class StudentSearchResults extends StatelessWidget {
  const StudentSearchResults({super.key, required this.controller});

  final StudentSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final query = controller.searchQuery.value;
      final results = controller.searchResults;

      // 1. If query is empty -> Show recent searches or initial placeholder
      if (query.isEmpty) {
        if (controller.recentSearches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_rounded,
            title: 'Search in LinkYetu',
            subtitle: 'Find all your enrolled classes, schedules, tasks, group study chats, and tools easily.',
          );
        }

        return _buildRecentSearchesSection();
      }

      // 2. If query is NOT empty but results are empty -> Show no results placeholder
      if (results.isEmpty) {
        return _buildEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results found',
          subtitle: 'We couldn\'t find any match for "$query" in category "${controller.selectedCategory.value}".',
        );
      }

      // 3. Otherwise show list of search results
      return ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 16.width,
          vertical: 8.height,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return _buildSearchResultCard(item);
        },
      );
    });
  }

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 8.height),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black0F172A,
                ),
              ),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: Text(
                  'Clear All',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.uiDangerColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.recentSearches.length,
            itemBuilder: (context, index) {
              final item = controller.recentSearches[index];
              return ListTile(
                leading: Icon(
                  Icons.history_rounded,
                  size: 20.fontSize,
                  color: AppColors.secondaryTextColor,
                ),
                title: Text(
                  item,
                  style: getTextStyle(
                    fontSize: 13,
                    color: AppColors.black0F172A,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close_rounded, size: 18.fontSize),
                  color: AppColors.secondaryTextColor,
                  onPressed: () => controller.removeRecentSearch(item),
                ),
                onTap: () {
                  controller.textController.text = item;
                  controller.textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: item.length),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.radius),
              decoration: const BoxDecoration(
                color: AppColors.panelBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.fontSize,
                color: AppColors.secondaryTextColor.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 16.height),
            Text(
              title,
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.black0F172A,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.height),
            Text(
              subtitle,
              style: getTextStyle(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult item) {
    IconData leadingIcon;
    Color iconColor;
    Color bgColor;
    String categoryLabel;

    switch (item.type) {
      case SearchResultType.course:
        leadingIcon = Icons.menu_book_rounded;
        iconColor = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        categoryLabel = 'Course';
        break;
      case SearchResultType.task:
        leadingIcon = Icons.task_alt_rounded;
        iconColor = AppColors.checkBoxActiveColor;
        bgColor = AppColors.createTaskButtonColorHomePage;
        categoryLabel = 'Task';
        break;
      case SearchResultType.chat:
        leadingIcon = Icons.chat_bubble_outline_rounded;
        iconColor = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        categoryLabel = 'Chat Group';
        break;
      case SearchResultType.tool:
        leadingIcon = Icons.auto_awesome_mosaic_rounded;
        iconColor = Colors.purple.shade700;
        bgColor = Colors.purple.shade50;
        categoryLabel = 'Quick Link';
        break;
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12.radius),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.height),
        padding: EdgeInsets.symmetric(horizontal: 14.width, vertical: 12.height),
        decoration: BoxDecoration(
          color: AppColors.panelBackgroundColor,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: AppColors.sectionBorderColor, width: 1.width),
        ),
        child: Row(
          children: [
            Container(
              height: 40.radius,
              width: 40.radius,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8.radius),
              ),
              child: Icon(leadingIcon, color: iconColor, size: 22.fontSize),
            ),
            SizedBox(width: 12.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryLabel,
                        style: getTextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.height),
                  Text(
                    item.title,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black0F172A,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.height),
                  Text(
                    item.subtitle,
                    style: getTextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.width),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.fontSize,
              color: AppColors.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
