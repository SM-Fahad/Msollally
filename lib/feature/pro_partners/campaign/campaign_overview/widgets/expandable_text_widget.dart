import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int maxLines;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    required this.style,
    required this.isExpanded,
    required this.onToggle,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final value = text.trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final spans = _buildSpans(value, style);

    final painter = TextPainter(
      text: TextSpan(children: spans, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 72.w);

    final hasOverflow = painter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(children: spans),
          style: style,
          maxLines: isExpanded ? null : maxLines,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (hasOverflow)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                isExpanded ? 'See less' : 'See more',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.royalBlue2563EB,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static List<InlineSpan> _buildSpans(String value, TextStyle style) {
    if (value.startsWith('[') && value.endsWith(']')) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          final spans = <InlineSpan>[];
          for (final op in decoded) {
            if (op is Map && op.containsKey('insert')) {
              final insert = op['insert']?.toString() ?? '';
              final attrs = op['attributes'] as Map?;
              final isBold = attrs?['bold'] == true;
              final isItalic = attrs?['italic'] == true;
              final isUnderline = attrs?['underline'] == true;

              spans.add(
                TextSpan(
                  text: insert,
                  style: style.copyWith(
                    fontWeight: isBold ? FontWeight.bold : style.fontWeight,
                    fontStyle: isItalic ? FontStyle.italic : style.fontStyle,
                    decoration: isUnderline
                        ? TextDecoration.underline
                        : style.decoration,
                  ),
                ),
              );
            }
          }
          if (spans.isNotEmpty) return spans;
        }
      } catch (_) {}
    }

    return _parseMarkdownSpans(value, style);
  }

  static List<InlineSpan> _parseMarkdownSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*([^*]+)\*\*)|(\*([^*]+)\*)|(<u>([^<]+)<\/u>)|(<b>([^<]+)<\/b>)|(<i>([^<]+)<\/i>)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(6) != null) {
        spans.add(TextSpan(
          text: match.group(6),
          style: baseStyle.copyWith(decoration: TextDecoration.underline),
        ));
      } else if (match.group(8) != null) {
        spans.add(TextSpan(
          text: match.group(8),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(10) != null) {
        spans.add(TextSpan(
          text: match.group(10),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }
}
