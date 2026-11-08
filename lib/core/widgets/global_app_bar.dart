import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 14) return 'Good Noon,';
    if (hour >= 14 && hour < 17) return 'Good Afternoon,';
    if (hour >= 17 && hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }
  final bool isHomePage;
  final String? title;
  final String? subtitle;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? profileImageUrl;
  final int notificationCount;
  final int messageCount;
  final double height;
  final Color backgroundColor;
  final List<Widget>? actions;

  const GlobalAppBar({
    super.key,
    this.isHomePage = false,
    this.title,
    this.subtitle,
    this.onSearchTap,
    this.onMessageTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileImageUrl,
    this.notificationCount = 0,
    this.messageCount = 0,
    this.height = 72,
    this.backgroundColor = AppColors.buttonColorOnboarding,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      padding: EdgeInsets.fromLTRB(20.width, 40.height, 20.width, 12.height),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: AppColors.appBarBottomColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isHomePage && canPop) ...[
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(12.radius),
                    child: Container(
                      height: 40.height,
                      width: 40.width,
                      decoration: BoxDecoration(
                        color: AppColors.ghostWhiteF5F7FB,
                        borderRadius: BorderRadius.circular(12.radius),
                        border: Border.all(color: AppColors.lavenderE6EBF2),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.fontSize,
                        color: AppColors.darkSlateGray1F2937,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.width),
                ],
                if (isHomePage) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _greeting(),
                            style: appTextStyleHeading1(
                              fontSize: 14.fontSize,
                              fontWeight: FontWeight.w400,
                              color: AppColors.appBarTitleColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(height: 1.height),
                        Flexible(
                          child: Text(
                            subtitle ?? title ?? '',
                            style: appTextStyleHeading1(
                              fontSize: 18.fontSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.appBarTitleColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (title != null) ...[
                  Expanded(
                    child: Text(
                      title!,
                      style: appTextStyleHeading1(
                        fontSize: 18.fontSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.appBarTitleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions != null) ...actions!,
              if (onMessageTap != null)
                InkWell(
                  onTap: onMessageTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        IconsPath.messageIcon,
                        height: 24.height,
                        width: 24.width,
                        colorFilter: const ColorFilter.mode(
                          AppColors.darkSlateGray1F2937,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (messageCount > 0)
                        Positioned(
                          right: -6.width,
                          top: -10.height,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.uiDangerColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20.width,
                              minHeight: 20.height,
                            ),
                            child: Center(
                              child: Text(
                                messageCount > 99
                                    ? '99+'
                                    : messageCount.toString(),
                                style: appTextStyleHeading1(
                                  fontSize: 10.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonColorOnboarding,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (onMessageTap != null) SizedBox(width: 16.width),
              if (onNotificationTap != null)
                InkWell(
                  onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ImageIcon(AssetImage(IconsPath.mainNotificationIcon)),
                      if (notificationCount > 0)
                        Positioned(
                          right: -6.width,
                          top: -10.height,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.uiDangerColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20.width,
                              minHeight: 20.height,
                            ),
                            child: Center(
                              child: Text(
                                notificationCount > 99
                                    ? '99+'
                                    : notificationCount.toString(),
                                style: appTextStyleHeading1(
                                  fontSize: 10.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonColorOnboarding,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (onNotificationTap != null) SizedBox(width: 16.width),
              if (onProfileTap != null)
                InkWell(
                  onTap: onProfileTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.radius),
                    child:
                        (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                        ? Image.network(
                            profileImageUrl!,
                            height: 40.height,
                            width: 40.width,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 40.height,
                                  width: 40.width,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 20.fontSize,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                          )
                        : Container(
                            height: 40.height,
                            width: 40.width,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 20.fontSize,
                              color: Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
