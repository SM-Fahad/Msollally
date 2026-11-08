import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../model/for_you_model.dart';

const _titleColor = Color(0xFF0F172A);
const _subtitleColor = Color(0xFF64748B);

class StudentHomeForYouTile extends StatelessWidget {
  const StudentHomeForYouTile({super.key, required this.item});

  final ForYouModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16.radius),
          highlightColor: const Color(0xFFF8FAFC),
          splashColor: const Color(0xFFEFF6FF),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 14.height),
            child: Row(
              children: [
                Container(
                  height: 48.height,
                  width: 48.width,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12.radius),
                  ),
                  padding: EdgeInsets.all(10.width),
                  child: Image.asset(
                    item.icon,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.info_outline_rounded,
                      color: const Color(0xFF0EA5E9),
                      size: 24.radius,
                    ),
                  ),
                ),
                SizedBox(width: 16.width),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: getTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _titleColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.height),
                      Text(
                        _subtitle(item),
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _subtitleColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.width),
                Container(
                  padding: EdgeInsets.all(8.width),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 14.radius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(ForYouModel item) {
    return item.subtitle;
  }
}
