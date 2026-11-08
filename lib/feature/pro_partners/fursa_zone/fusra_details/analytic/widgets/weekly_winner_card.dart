import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class WeeklyWinnerCard extends StatelessWidget {
  const WeeklyWinnerCard({super.key, required this.prize, required this.index});

  final Map<String, dynamic> prize;
  final int index;

  @override
  Widget build(BuildContext context) {
    final title = '${prize['title'] ?? prize['name'] ?? ''}'.trim();
    final winnerName =
        '${prize['winnerName'] ?? prize['winner'] ?? prize['userName'] ?? ''}'
            .trim();
    final points = '${prize['points'] ?? prize['score'] ?? prize['mark'] ?? ''}'
        .trim();
    final amount =
        '${prize['amount'] ?? prize['value'] ?? prize['prizeAmount'] ?? ''}'
            .trim();
    final imageUrl =
        '${prize['imageUrl'] ?? prize['image'] ?? prize['icon'] ?? ''}'.trim();
    final rank = '${prize['rank'] ?? prize['position'] ?? ''}'.trim();
    final rankNumber = int.tryParse(rank.trim()) ?? (index + 1);
    final displayRank = _toOrdinal(rank, index + 1);
    final colors = _rankColors(rankNumber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surfaceStart, colors.surfaceEnd],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              displayRank,
              style: getTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (winnerName.isNotEmpty) ...[
                  Text(
                    winnerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkSlateGray1F2937,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (points.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$points pts',
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkSlateGray374151,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryTextColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (amount.isNotEmpty)
                  Text(
                    amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.priceColor,
                      height: 1.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _PrizeImage(imageUrl: imageUrl),
        ],
      ),
    );
  }

  String _toOrdinal(String rawRank, int fallbackValue) {
    final value = int.tryParse(rawRank.trim()) ?? fallbackValue;
    if (value <= 0) return '1st';
    if (value % 100 >= 11 && value % 100 <= 13) return '${value}th';
    switch (value % 10) {
      case 1:
        return '${value}st';
      case 2:
        return '${value}nd';
      case 3:
        return '${value}rd';
      default:
        return '${value}th';
    }
  }
}

class _CardRankColors {
  const _CardRankColors({
    required this.surfaceStart,
    required this.surfaceEnd,
    required this.borderColor,
    required this.badgeColor,
    required this.priceColor,
    required this.shadowColor,
  });

  final Color surfaceStart;
  final Color surfaceEnd;
  final Color borderColor;
  final Color badgeColor;
  final Color priceColor;
  final Color shadowColor;
}

_CardRankColors _rankColors(int rank) {
  switch (rank) {
    case 1:
      return const _CardRankColors(
        surfaceStart: AppColors.oldLaceFFF5E8,
        surfaceEnd: AppColors.blanchedAlmondFCE9D1,
        borderColor: AppColors.sandyBrownFFA94D,
        badgeColor: AppColors.darkOrangeFF7A00,
        priceColor: AppColors.chocolateC45500,
        shadowColor: AppColors.coralAlpha26FF9B3A,
      );
    case 2:
      return const _CardRankColors(
        surfaceStart: AppColors.ivoryFFFDEB,
        surfaceEnd: AppColors.beigeF7F4D7,
        borderColor: AppColors.sandyBrownE5C95A,
        badgeColor: AppColors.orangeE0AA00,
        priceColor: AppColors.olive9B7700,
        shadowColor: AppColors.sandyBrownAlpha20D8C15A,
      );
    case 3:
      return const _CardRankColors(
        surfaceStart: AppColors.ghostWhiteF6F8FB,
        surfaceEnd: AppColors.lavenderE8ECF2,
        borderColor: AppColors.silverB5C0CF,
        badgeColor: AppColors.darkGray8E9AAF,
        priceColor: AppColors.dimGray5C677A,
        shadowColor: AppColors.darkGrayAlpha1F9AA5B4,
      );
    default:
      return const _CardRankColors(
        surfaceStart: AppColors.ghostWhiteF9FAFB,
        surfaceEnd: AppColors.whiteSmokeF2F4F7,
        borderColor: AppColors.gainsboroD8DEE8,
        badgeColor: AppColors.secondaryTextColor,
        priceColor: AppColors.darkSlateGray374151,
        shadowColor: AppColors.blackAlpha16000000,
      );
  }
}

class _PrizeImage extends StatelessWidget {
  const _PrizeImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 92,
        height: 92,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.bisqueFFE2C2,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.emoji_events_outlined,
        color: AppColors.firebrickC2410C,
        size: 30,
      ),
    );
  }
}
