import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/student/campus/chat/screen/chat_screen.dart';
import 'package:msollaally/routes/app_route.dart';

import '../../../../../../core/common/widgets/custom_button.dart';
import '../../controller/gigs_controller.dart';
import '../../model/gigs_model.dart';
import 'gig_detail_content_sections.dart';
import 'gig_detail_header.dart';
import 'gig_detail_meta_sections.dart';

class GigDetailCard extends StatelessWidget {
  const GigDetailCard({super.key, required this.gig});

  final GigsModel gig;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<GigsController>()
        ? Get.find<GigsController>()
        : Get.put(GigsController());

    return FutureBuilder<int>(
      future: controller.getCurrentUserId(),
      builder: (context, snapshot) {
        final currentUserId = (snapshot.hasData && snapshot.data != null && snapshot.data! > 0)
            ? snapshot.data!
            : controller.currentUserId.value;
        final isOwner = (currentUserId > 0 &&
                gig.author != null &&
                gig.author!.id == currentUserId) ||
            (gig.gigId != null &&
                controller.myGigs.any((g) => g.gigId == gig.gigId));

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.width),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GigDetailHeader(gig: gig),
              SizedBox(height: 14.height),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 14.height),
              GigDetailMetaSections(gig: gig),
              GigDetailContentSections(gig: gig),
              if (!isOwner) ...[
                SizedBox(height: 30.height),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Contact Me',
                    onPressed: () {
                      final author = gig.author;
                      if (author != null && author.id > 0) {
                        if (author.id == currentUserId) {
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
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
