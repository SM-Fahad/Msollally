import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/feature/student/campus/campus_home/model/leaderboard_model.dart';

class LeaderboardItemWidget extends StatelessWidget {
  final StudentCampusLeaderboardModel model;
  final bool isCurrentUser;

  const LeaderboardItemWidget({
    super.key,
    required this.model,
    this.isCurrentUser = false,
  });
  Color _getBackgroundColor(int rank) {
    if (isCurrentUser) return AppColors.lavenderF3E8FF;
    switch (rank) {
      case 1:
        return AppColors.lemonChiffonFEF9C3;
      case 2:
        return AppColors.tagBackgroundColor;
      case 3:
        return AppColors.papayaWhipFFEDD5;
      default:
        return Colors.white;
    }
  }

  Color _getBorderColor(int rank) {
    if (isCurrentUser) return AppColors.plumD8B4FE;
    switch (rank) {
      case 1:
        return AppColors.sandyBrownFDE047;
      case 2:
        return AppColors.tagBorderColor;
      case 3:
        return AppColors.lightSalmonFDBA74;
      default:
        return AppColors.tagBackgroundColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _getBackgroundColor(model.rank),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor(model.rank), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: model.rank <= 3
                ? Image.asset(
                    model.rank == 1
                        ? IconsPath.firstposition
                        : model.rank == 2
                        ? IconsPath.secondposition
                        : IconsPath.thirdposition,
                    height: 24,
                  )
                : Text(
                    "#${model.rank}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.violetC27AFF, AppColors.cornflowerBlue51A2FF],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(child: Image.asset(model.emoji, width: 28)),
          ),

          const SizedBox(width: 12),
          // Name and Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCurrentUser ? "You 🚀" : model.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (model.rank == 1)
                      const Text(" 🔥", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  model.streakDays != null
                      ? "🔥 ${model.streakDays} day streak"
                      : "${model.weeklyWins} weekly wins",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColors.blueViolet9333EA
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              model.rank <= 3 && !isCurrentUser
                  ? "${model.points} pts"
                  : isCurrentUser
                  ? "${model.points} pts"
                  : "${model.points}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
