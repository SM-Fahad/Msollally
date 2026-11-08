// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/routes/app_route.dart';

class StudentHomeQuickTools extends StatelessWidget {
  const StudentHomeQuickTools({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool(
        'Calendar',
        IconsPath.calenderNodMac,
        AppRoute.studentCalenderPage,
        const Color(0xFF8757F3),
        const Color(0xFF8757F3),
      ),
      _Tool(
        'Convert',
        IconsPath.convertFileIcon,
        AppRoute.studentFileConverterPage,
        const Color(0xFFFF9244),
        AppColors.black0F172A,
      ),
      _Tool(
        'AI Chat',
        IconsPath.aiChatIcon,
        AppRoute.studentAIChatpage,
        const Color(0xFF418AFF),
        AppColors.black0F172A,
      ),
      _Tool(
        'Task Creator',
        IconsPath.createButtonIconIcon,
        AppRoute.studentCreateTask,
        const Color(0xFFFD294E),
        AppColors.black0F172A,
      ),
    ];

    return Row(
      children: tools
          .map(
            (tool) => Expanded(
              child: InkWell(
                onTap: () => Get.toNamed(tool.route),
                borderRadius: BorderRadius.circular(12.radius),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.height),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 46.height,
                        width: 46.width,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tool.color.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: tool.color.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          tool.icon,
                          height: 22.height,
                          width: 22.width,
                          colorFilter: ColorFilter.mode(
                            tool.color,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(height: 7.height),
                      Text(
                        tool.label,
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tool.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Tool {
  const _Tool(this.label, this.icon, this.route, this.color, this.textColor);

  final String label;
  final String icon;
  final String route;
  final Color color;
  final Color textColor;
}
