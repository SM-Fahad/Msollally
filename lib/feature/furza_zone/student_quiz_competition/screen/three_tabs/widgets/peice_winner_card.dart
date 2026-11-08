import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PrizeWinnerCard extends StatelessWidget {
  final String rank;
  final String userName;
  final String points;
  final String price;
  final String imagePath;

  final Color gradientStartColor;
  final Color gradientEndColor;
  final Color avatarBackgroundColor;
  final Color borderColor;

  const PrizeWinnerCard({
    super.key,
    required this.rank,
    required this.userName,
    required this.points,
    required this.price,
    required this.imagePath,
    this.gradientStartColor = AppColors.seaShellFFF7ED,
    this.gradientEndColor = AppColors.papayaWhipFFEDD4,
    this.avatarBackgroundColor = AppColors.orangeRedFF570D,
    this.borderColor = AppColors.coralFF9933,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStartColor, gradientEndColor],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: avatarBackgroundColor,
            child: Text(
              rank,
              style: getTextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkSlateGray1D2939,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.lavenderE4E7EC),
                      ),
                      child: Text(
                        "$points pts",
                        style: getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkSlateGray344054,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: \$$price',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkSlateGray1D2939,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildImage(imagePath),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return const SizedBox(
        height: 60,
        width: 60,
        child: Icon(Icons.emoji_events, color: Colors.orange, size: 30),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: 60,
        width: 60,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 60,
            width: 60,
            child: Icon(Icons.emoji_events, color: Colors.orange, size: 30),
          );
        },
      );
    }
    return Image.asset(
      path,
      height: 60,
      width: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          height: 60,
          width: 60,
          child: Icon(Icons.emoji_events, color: Colors.orange, size: 30),
        );
      },
    );
  }
}
