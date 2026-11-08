import 'package:flutter/material.dart';
import 'package:msollaally/core/common/widgets/video_player_preview.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/event_overview_controller.dart';
import 'package:msollaally/feature/pro_partners/events/all_events/model/event_model.dart';
import '../widgets/analytics_tab_widget.dart';
import '../widgets/social_feed_tab_widget.dart';
import '../widgets/attendees_tab_widget.dart';

class EventOverviewScreen extends StatelessWidget {
  final String title;
  final EventModel? event;

  EventOverviewScreen({super.key, this.event})
    : title = event?.title ?? 'Tech Innovation Workshop';

  int? get _eventId => int.tryParse(event?.id ?? '');
  String get _controllerTag => 'event_overview_${event?.id ?? "unknown"}';

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EventOverviewController>(tag: _controllerTag)) {
      Get.put(EventOverviewController(eventId: _eventId), tag: _controllerTag);
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (event != null &&
                (event!.mediaUrl.isNotEmpty || event!.coverImageUrl.isNotEmpty))
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                child: event!.mediaUrl.isNotEmpty
                    ? VideoPlayerPreviewWidget(
                        remoteUrl: event!.mediaUrl,
                        height: 170.h,
                        borderRadius: 12.r,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          event!.coverImageUrl,
                          height: 170.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
              ),
            TabBar(
              labelColor: AppColors.primaryButtonColor,
              unselectedLabelColor: AppColors.gray7A7A7A,
              tabs: [
                Tab(text: 'Analytics'),
                Tab(text: 'Social Feed'),
                Tab(text: 'Attendees'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AnalyticsTabWidget(controllerTag: _controllerTag),
                  SocialFeedTabWidget(controllerTag: _controllerTag),
                  AttendeesTabWidget(controllerTag: _controllerTag),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
