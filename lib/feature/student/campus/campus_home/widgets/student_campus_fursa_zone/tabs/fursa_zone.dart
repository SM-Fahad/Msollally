import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/competition_registration_dialogbox.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/digital_brochure_dialog.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/product_training_video_dialog.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/learning_phase_alert.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/fursa_zone_screen/widgets/participation_and_register.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/participation_guidance_dialogbox.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/task_action_card.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/campus/campus_home/controller/student_campus_controller.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/controller/dialogbox_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/fursa_zone_screen/widgets/bonus_points_card.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/student_campus_fursa_zone/fursa_zone_screen/widgets/qualification_card.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/quiz_info_dialog.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/dialog_boxes/final_quiz_dialog.dart';

class FursaZone extends StatelessWidget {
  const FursaZone({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DialogboxController());
    return GetBuilder<StudentCampusController>(
      builder: (controller) {
        return Obx(() {
          if (controller.isLoadingFursaZone.value) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ShimmerLoading.card(height: 180, borderRadius: 16),
                  const SizedBox(height: 20),
                  ShimmerLoading.card(height: 80, borderRadius: 12),
                  const SizedBox(height: 28),
                  ShimmerLoading.list(
                    itemCount: 3,
                    height: 90,
                    borderRadius: 12,
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Image
                if (controller.fursaZoneBannerImage.value.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        controller.fursaZoneBannerImage.value.startsWith('http')
                        ? Image.network(
                            controller.fursaZoneBannerImage.value,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            controller.fursaZoneBannerImage.value,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                const SizedBox(height: 16),

                // Competition Title and Sponsor
                if (controller.competitionsList.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final activeComp = controller.competitionsList.first;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (controller
                                  .fursaZoneSponsorImage
                                  .value
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      controller.fursaZoneSponsorImage.value,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                          const Icon(Icons.business),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeComp.competitionName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (activeComp.brandSlogan != null &&
                                        activeComp.brandSlogan!.isNotEmpty)
                                      Text(
                                        activeComp.brandSlogan!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (activeComp.competitionGuidelines != null &&
                              activeComp.competitionGuidelines!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Guidelines & Description",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Html(
                                    data: activeComp.competitionGuidelines,
                                    style: {
                                      "body": Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                        fontSize: FontSize(14.0),
                                        color: Colors.grey.shade700,
                                      ),
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Registration Phase
                          if (!activeComp.isRegistered) ...[
                            ParticipationAndRegister(
                              onParticipationTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      ParticipationGuidanceDialogbox(
                                        competition: activeComp,
                                      ),
                                );
                              },
                              onRegisterTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CompetitionRegistrationDialog(
                                    competitionId: activeComp.id,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Roadmap 
                          ..._buildPhaseRoadmap(
                            context,
                            controller,
                            activeComp,
                          ),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  // No active competition fallback
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "No Active Competition",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          );
        });
      },
    );
  }

  List<Widget> _buildPhaseRoadmap(
    BuildContext context,
    StudentCampusController controller,
    var activeComp,
  ) {
    bool isRegistered = activeComp.isRegistered;
    String status = activeComp.status; 

    int getPhaseIndex(String status) {
      if (status == 'LEARNING_PHASE') return 0;
      if (status == 'QUALIFICATION_QUIZ') return 1;
      if (status == 'WEEKLY_FINAL') return 2;
      if (status == 'FINAL_COMPLETED') return 3;
      if (status == 'COMPLETED') return 4;
      return -1;
    }

    int currentPhaseIndex = getPhaseIndex(status);
    
    bool isLearningPhaseActive = isRegistered && currentPhaseIndex == 0;
    bool isLearningPhaseCompleted = isRegistered && currentPhaseIndex > 0;
    bool isLearningPhaseLocked = !isRegistered || currentPhaseIndex < 0;

    bool isQualPhaseActive = isRegistered && currentPhaseIndex == 1;
    bool isQualPhaseCompleted = isRegistered && currentPhaseIndex > 1;
    bool isQualPhaseLocked = !isRegistered || currentPhaseIndex < 1;

    bool isWeeklyFinalActive = isRegistered && currentPhaseIndex >= 2;
    bool isWeeklyFinalCompleted = isRegistered && currentPhaseIndex > 2;
    bool isWeeklyFinalLocked = !isRegistered || currentPhaseIndex < 2;

    List<Widget> widgets = [];

    if (isRegistered) {
      widgets.add(const BonusCard());
      widgets.add(const SizedBox(height: 16));
    }

    // Learning Phase
    widgets.add(
      CustomPhaseCard(
        title: 'Learning Phase',
        isLocked: isLearningPhaseLocked,
        isCompleted: isLearningPhaseCompleted,
        isActive: isLearningPhaseActive,
        lockedMessage: isRegistered ? 'This phase is not active yet.' : 'Register first to unlock this phase.',
        child: Column(
          children: [
            Obx(() => LearningPhaseAlert(
              isCompleted: controller.taskCompleted['learning_phase_completed'] ?? false,
            )),
            const SizedBox(height: 16),
            TaskActionCard(
              taskKey: 'video_task',
              title: 'Watch Product Clip',
              taskColor: const Color(0xFFA855F7), // Purple
              buttonText: 'WATCH CLIP',
              taskIcon: Icons.video_call_outlined,
              subtitle: 'Learn about loan products',
              points: '+${activeComp.videoPoints} pts',
              buttonColor: AppColors.black0F1117,
              isEnabled: true,
              onTaskCompleted: () {
                showDialog(
                  context: context,
                  builder: (_) => ProductTrainingVideoDialog(
                    videoUrl: activeComp.promoVideoLink,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TaskActionCard(
              taskKey: 'brochure_task',
              title: 'Read Digital Brochure',
              taskColor: const Color(0xFF3B82F6), // Blue
              buttonText: 'READ CONTENTS',
              taskIcon: Icons.menu_book_outlined,
              subtitle: 'Complete product materials',
              points: '+${activeComp.brochurePoints} pts',
              buttonColor: AppColors.black0F1117,
              isEnabled: true,
              onTaskCompleted: () {
                showDialog(
                  context: context,
                  builder: (_) => DigitalBrochureDialog(
                    brochureUrl: activeComp.partnerInfoFileLink,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TaskActionCard(
              taskKey: 'chat_task',
              title: 'Q&A Discussion',
              taskColor: const Color(0xFFF97316), // Orange
              buttonText: 'Q&A',
              taskIcon: Icons.chat_outlined,
              subtitle: 'Ask AI about products',
              points: '+${activeComp.qnaPoints} pts',
              buttonColor: const Color(0xFFF97316), // Orange
              isEnabled: true,
              onTaskCompleted: () {
                Get.toNamed('/student/home/aichat');
              },
            ),
          ],
        ),
      ),
    );

    // Qualification Quiz
    widgets.add(const SizedBox(height: 16));
    widgets.add(
      GestureDetector(
        onTap: isQualPhaseLocked ? () {
          EasyLoading.showInfo(isRegistered ? 'This phase is not active yet.' : 'Register first to unlock this phase.');
        } : null,
        child: Obx(() => QuizCard(
          isEnabled: !isQualPhaseLocked,
          isCompleted: controller.taskCompleted['qualification_phase_completed'] ?? false,
          title: "Qualification Quiz",
          subtitle: isQualPhaseActive ? "Stage 2 is active" : "Starts on ${activeComp.qualificationDate?.toLocal().toString().split(' ')[0] ?? 'TBD'}",
          tagText: "Stage 2",
          tagColor: AppColors.dodgerBlue1D61FF,
          buttonActiveColor: AppColors.dodgerBlue1D61FF,
          borderColor: AppColors.dodgerBlue1D61FF,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const QuizInfoDialog(),
            );
          },
        )),
      ),
    );

    // Weekly Final
    widgets.add(const SizedBox(height: 16));
    widgets.add(
      GestureDetector(
        onTap: isWeeklyFinalLocked ? () {
          EasyLoading.showInfo(isRegistered ? 'This phase is not active yet.' : 'Register first to unlock this phase.');
        } : null,
        child: Obx(() => QuizCard(
          isEnabled: !isWeeklyFinalLocked,
          isCompleted: controller.taskCompleted['final_phase_completed'] ?? false,
          title: "Weekly Final",
          subtitle: isWeeklyFinalActive ? "Stage 3 is active" : "Starts on ${activeComp.finalCompetitionDate?.toLocal().toString().split(' ')[0] ?? 'TBD'}",
          tagText: "Stage 3",
          tagColor: AppColors.orangeRedF54900,
          buttonActiveColor: AppColors.orangeRedF54900,
          bgColor: AppColors.navajoWhiteAlpha66FFD6A7,
          icon: Icons.emoji_events_outlined,
          iconColor: AppColors.orangeRedF54900,
          borderColor: AppColors.orangeRedF54900,
          buttonText: "Start Weekly Final",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const FinalQuizDialog(),
            );
          },
        )),
      ),
    );

    return widgets;
  }
}

class CustomPhaseCard extends StatefulWidget {
  final String title;
  final bool isLocked;
  final bool isCompleted;
  final bool isActive;
  final String lockedMessage;
  final Widget child;

  const CustomPhaseCard({
    super.key,
    required this.title,
    required this.isLocked,
    required this.isCompleted,
    required this.isActive,
    required this.child,
    this.lockedMessage = 'Register first to unlock this phase.',
  });

  @override
  State<CustomPhaseCard> createState() => _CustomPhaseCardState();
}

class _CustomPhaseCardState extends State<CustomPhaseCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isActive;
  }

  @override
  void didUpdateWidget(CustomPhaseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _expanded = widget.isActive;
    }
  }

  void _handleTap() {
    if (widget.isLocked) {
      EasyLoading.showInfo(widget.lockedMessage);
      return;
    }
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isLocked ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isActive ? AppColors.blueViolet9333EA : Colors.grey.shade200,
          width: widget.isActive ? 1.5 : 1.0,
        ),
        boxShadow: widget.isActive 
          ? [BoxShadow(color: AppColors.blueViolet9333EA.withOpacity(0.1), blurRadius: 8)] 
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (widget.isCompleted)
                    const Icon(Icons.check_circle, color: Colors.green, size: 24)
                  else if (widget.isLocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 24)
                  else if (widget.isActive)
                    const Icon(Icons.play_circle_fill, color: AppColors.blueViolet9333EA, size: 24)
                  else
                    const Icon(Icons.circle_outlined, color: Colors.grey, size: 24),
                  
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: widget.isLocked ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: widget.isLocked ? Colors.grey : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: widget.child,
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
