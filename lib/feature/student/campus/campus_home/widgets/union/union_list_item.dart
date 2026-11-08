import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/union_model.dart';

class UnionListItem extends StatelessWidget {
  const UnionListItem({
    super.key,
    required this.item,
    required this.showStatus,
  });

  final UnionModel item;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.height),
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 12.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.radius),
        border: Border.all(
          color: AppColors.black000000.withValues(alpha: .12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                SizedBox(width: 8.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildName(),
                      _buildInfo(),
                      if (showStatus) _buildStatus(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildViewButton(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final imageUrl =
        (item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty)
        ? item.coverImageUrl
        : item.logoUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.radius),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 40.height,
              width: 40.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.group, size: 40.height),
            )
          : Container(
              height: 40.height,
              width: 40.width,
              color: Colors.grey[200],
              child: const Icon(Icons.group, color: Colors.grey),
            ),
    );
  }

  Widget _buildName() {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoute.studentCampusUnion, arguments: item);
      },
      child: Text(
        item.name,
        style: appTextStyleHeading1(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildInfo() {
    return Text(
      "${item.memberCount} Members • ${item.category}",
      style: appTextStyleHeading2(fontSize: 12.fontSize),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: EdgeInsets.only(top: 4.height),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 2.height),
        decoration: BoxDecoration(
          color: _getStatusColor(item.status).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(4.radius),
        ),
        child: Text(
          (item.status.replaceAll('_', ' ').capitalizeFirst) ?? item.status,
          style: TextStyle(
            color: _getStatusColor(item.status),
            fontSize: 10.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton() {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoute.studentCampusUnion, arguments: item);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 6.height),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.radius),
          border: Border.all(color: AppColors.primaryButtonColor),
        ),
        child: Text(
          "View",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -.5.fontSize,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending_approval':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
