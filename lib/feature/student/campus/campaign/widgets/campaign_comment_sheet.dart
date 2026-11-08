import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../../../../../core/const/images_path.dart';
import '../../../../../core/common/widgets/shimmer_loading.dart';
import '../controller/campaign_detail_controller.dart';

void showCampaignCommentSheet(BuildContext context, String campaignId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (_) => CampaignCommentSheet(campaignId: campaignId),
  );
}

class CampaignCommentSheet extends StatelessWidget {
  final String campaignId;
  const CampaignCommentSheet({super.key, required this.campaignId});

  CampaignDetailController get _c =>
      Get.find<CampaignDetailController>(tag: campaignId);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.5, 0.75, 0.95],
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.radius)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.height),
                child: Container(
                  width: 40.width,
                  height: 5.height,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayCED0D4,
                    borderRadius: BorderRadius.circular(4.radius),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.width, 0, 4.width, 8.height),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final details = _c.campaignDetails.value;
                      final count = details?['commentCount'] ?? '0';
                      return Text(
                        int.parse(count) > 0 ? 'Comments ($count)' : 'Comments',
                        style: getTextStyle(
                          fontSize: 16.fontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      );
                    }),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      onPressed: Get.back,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Comments List
              Expanded(
                child: Obx(() {
                  final details = _c.campaignDetails.value;
                  if (_c.isLoading.value && details == null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.width,
                        vertical: 16.height,
                      ),
                      child: ShimmerLoading.list(
                        itemCount: 4,
                        height: 60.height,
                        borderRadius: 12.radius,
                      ),
                    );
                  }

                  final comments =
                      (details?['comments'] as List<dynamic>?) ?? [];

                  if (comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 56.fontSize,
                            color: AppColors.lavenderE4E6EA,
                          ),
                          SizedBox(height: 12.height),
                          Text(
                            'No comments yet',
                            style: getTextStyle(
                              fontSize: 15.fontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 4.height),
                          Text(
                            'Be the first to share your thoughts!',
                            style: getTextStyle(
                              fontSize: 13.fontSize,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollCtrl,
                    padding: EdgeInsets.only(top: 8.height, bottom: 8.height),
                    itemCount: comments.length,
                    itemBuilder: (_, i) => _CommentItem(comment: comments[i]),
                  );
                }),
              ),

              const Divider(height: 1, thickness: 0.5),

              // Input Bar
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12.height,
                  left: 12.width,
                  right: 12.width,
                  top: 10.height,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _c.commentController,
                        focusNode: _c.commentFocusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a comment…',
                          hintStyle: getTextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: AppColors.whiteSmokeF0F2F5,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.width,
                            vertical: 10.height,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22.radius),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.width),
                    Obx(
                      () => _c.isSubmittingComment.value
                          ? Padding(
                              padding: EdgeInsets.all(10.width),
                              child: SizedBox(
                                width: 22.width,
                                height: 22.height,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _c.submitComment,
                              child: Container(
                                width: 40.width,
                                height: 40.width,
                                decoration: const BoxDecoration(
                                  color: AppColors.dodgerBlue0866FF,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20.fontSize,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentItem extends StatelessWidget {
  final dynamic comment;
  const _CommentItem({required this.comment});

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'just now';
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return 'just now';
      final diff = DateTime.now().difference(parsed);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final author = comment['author'] ?? {};
    final authorName = (author['username'] ?? author['fullName'] ?? 'Anonymous')
        .toString();
    final avatar = (author['profilePicture'] ?? '').toString();
    final content = (comment['content'] ?? '') as String;
    final createdAt = comment['createdAt']?.toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 6.height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipOval(
            child: avatar.isNotEmpty
                ? Image.network(
                    avatar,
                    width: 34.width,
                    height: 34.width,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                  )
                : _avatarPlaceholder(),
          ),
          SizedBox(width: 10.width),

          // Bubble & Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.width,
                    vertical: 8.height,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteSmokeF0F2F5,
                    borderRadius: BorderRadius.circular(18.radius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: getTextStyle(
                          fontSize: 13.fontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2.height),
                      Text(
                        content,
                        style: getTextStyle(
                          fontSize: 13.5.fontSize,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.width, top: 4.height),
                  child: Text(
                    _formatTime(createdAt),
                    style: getTextStyle(
                      fontSize: 11.fontSize,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Image.asset(
      ImagesPath.profilePNG,
      width: 34.width,
      height: 34.width,
      fit: BoxFit.cover,
    );
  }
}
