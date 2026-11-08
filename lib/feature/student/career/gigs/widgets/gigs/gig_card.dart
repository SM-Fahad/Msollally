import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/student/campus/chat/screen/chat_screen.dart';
import 'package:msollaally/routes/app_route.dart';

import '../../controller/gigs_controller.dart';
import '../../model/gigs_model.dart';
import '../../screen/create_gig_screen.dart';
import '../../screen/gig_details.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import 'package:msollaally/core/common/widgets/fullscreen_video_view.dart';

class GigCard extends StatelessWidget {
  const GigCard({
    super.key,
    required this.gig,
    this.isMyGig = false,
  });

  final GigsModel gig;
  final bool isMyGig;

  bool _hasVideo(List<String> documents) {
    if (documents.isEmpty) return false;
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.mkv',
      '.flv',
      '.wmv',
      '.webm',
    ];
    return documents.any((doc) {
      final lowercaseDoc = doc.toLowerCase();
      return videoExtensions.any((ext) => lowercaseDoc.contains(ext));
    });
  }

  void _showDeleteDialog(BuildContext context, GigsController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Gig'),
        content: const Text(
          'Are you sure you want to delete this gig? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (gig.gigId != null) {
                controller.deleteGig(gig.gigId!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<GigsController>()
        ? Get.find<GigsController>()
        : Get.put(GigsController());

    final currentUserId = controller.currentUserId.value;
    final isOwner = (currentUserId != -1 &&
            gig.author != null &&
            gig.author!.id == currentUserId) ||
        (gig.gigId != null &&
            controller.myGigs.any((g) => g.gigId == gig.gigId));

    final status = (gig.status ?? 'active').toLowerCase();
    final isActive = status == 'active';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.height),
      child: GestureDetector(
        onTap: () => Get.to(() => const GigDetailScreen(), arguments: gig),
        child: Container(
          padding: EdgeInsets.all(16.width),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gainsboroE5E5E5),
            borderRadius: BorderRadius.circular(20.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title & Status / Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      gig.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyleHeading1(
                        fontSize: 18.fontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black1F1F1F,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.width),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.width,
                      vertical: 3.height,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.radius),
                      border: Border.all(
                        color: isActive ? Colors.green.shade300 : Colors.orange.shade300,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Paused',
                      style: TextStyle(
                        fontSize: 11.fontSize,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.green.shade700 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.height),
              // Subtitle / Description
              Text(
                gig.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appTextStyleHeading2(
                  fontSize: 14.fontSize,
                  color: AppColors.gray757575,
                ),
              ),
              SizedBox(height: 12.height),
              // Media Section
              if (gig.documents.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    if (_hasVideo(gig.documents)) {
                      Get.to(() => FullscreenVideoView(videoUrl: gig.documents.first));
                    } else {
                      Get.to(() => FullscreenImageView(
                        imageUrl: gig.documents.first,
                        isNetworkImage: true,
                      ));
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: 140.height,
                          maxHeight: 220.height,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.todaysQuickPicContainerBGColor,
                          borderRadius: BorderRadius.circular(14.radius),
                          border: Border.all(color: AppColors.whiteSmokeEEEEEE),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.radius),
                          child: Image.network(
                            gig.documents.first,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      if (_hasVideo(gig.documents))
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              height: 48.height,
                              width: 48.height,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32.fontSize,
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          top: 8.height,
                          right: 8.width,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.width, vertical: 4.height),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6.radius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14.fontSize),
                                SizedBox(width: 4.width),
                                Text(
                                  'Zoom',
                                  style: TextStyle(color: Colors.white, fontSize: 10.fontSize, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.height),
              ],
              Divider(color: AppColors.whiteSmokeEEEEEE, height: 1.height),
              SizedBox(height: 10.height),
              // Footer Row 1: Price Pill & Tags
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.width,
                      vertical: 5.height,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.honeydewEDF7ED,
                      borderRadius: BorderRadius.circular(50.radius),
                    ),
                    child: Text(
                      '${gig.currency} ${gig.price} / ${gig.pricingType == "hourly" ? "hr" : gig.pricingType}',
                      style: appTextStyleHeading2(
                        fontSize: 13.fontSize,
                        color: AppColors.mediumSeaGreen4CAF50,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (gig.locationType.isNotEmpty) ...[
                    SizedBox(width: 8.width),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.width,
                        vertical: 5.height,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.radius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_outlined, size: 13.fontSize, color: Colors.grey.shade700),
                          SizedBox(width: 3.width),
                          Text(
                            gig.locationType[0].toUpperCase() + gig.locationType.substring(1),
                            style: TextStyle(
                              fontSize: 11.fontSize,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.height),
              // Footer Row 2: Action Buttons
              if (isOwner) ...[
                Row(
                  children: [
                    // Status Toggle
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.height),
                          side: BorderSide(
                            color: isActive ? Colors.orange.shade400 : Colors.green.shade400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.radius),
                          ),
                        ),
                        icon: Icon(
                          isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          size: 16.fontSize,
                          color: isActive ? Colors.orange.shade700 : Colors.green.shade700,
                        ),
                        label: Text(
                          isActive ? 'Pause' : 'Activate',
                          style: TextStyle(
                            fontSize: 12.fontSize,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ),
                        onPressed: () {
                          if (gig.gigId != null) {
                            controller.toggleGigStatus(
                              gig.gigId!,
                              isActive ? 'paused' : 'active',
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8.width),
                    // Edit
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.height),
                          side: BorderSide(color: Colors.blue.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.radius),
                          ),
                        ),
                        icon: Icon(Icons.edit_outlined, size: 16.fontSize, color: Colors.blue),
                        label: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12.fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          controller.populateFormForEdit(gig);
                          Get.to(() => const CreateGigScreen());
                        },
                      ),
                    ),
                    SizedBox(width: 8.width),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete Gig',
                      onPressed: () => _showDeleteDialog(context, controller),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View Details Button
                    OutlinedButton(
                      onPressed: () =>
                          Get.to(() => const GigDetailScreen(), arguments: gig),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gainsboroE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.radius),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.width,
                          vertical: 8.height,
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: appTextStyleHeading2(
                          fontSize: 13.fontSize,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    ),
                    // Contact Me Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.radius),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.width,
                          vertical: 8.height,
                        ),
                      ),
                      icon: Icon(Icons.chat_bubble_outline, size: 15.fontSize),
                      label: Text(
                        'Contact Me',
                        style: TextStyle(
                          fontSize: 13.fontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        final author = gig.author;
                        if (author != null && author.id > 0) {
                          if (author.id == controller.currentUserId.value) {
                            Get.snackbar(
                              'Notice',
                              'This is your own gig.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          if (UserRoleService.isTeacher) {
                            Get.toNamed(
                              AppRoute.teacherChatScreen,
                              arguments: {
                                'reciverId': author.id.toString(),
                                'receiverId': author.id,
                                'receiverIds': [author.id],
                                'name': author.username ?? 'Publisher',
                                'chatName': author.username ?? 'Publisher',
                                'isGroup': false,
                              },
                            );
                          } else {
                            Get.to(
                              () => CampusChatScreen(),
                              arguments: {
                                'receiverId': author.id,
                                'receiverIds': [author.id],
                                'name': author.username ?? 'Publisher',
                                'chatName': author.username ?? 'Publisher',
                                'isGroup': false,
                              },
                            );
                          }
                        } else {
                          Get.snackbar(
                            'Unavailable',
                            'Publisher information is not available for this gig.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
