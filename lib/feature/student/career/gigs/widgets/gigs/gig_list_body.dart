import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import 'package:msollaally/core/common/widgets/shimmer_loading.dart';

import '../../controller/gigs_controller.dart';
import 'gig_card.dart';

class GigListBody extends StatelessWidget {
  const GigListBody({
    super.key,
    required this.controller,
    this.isMyGigs = false,
  });

  final GigsController controller;
  final bool isMyGigs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = isMyGigs ? controller.isMyGigsLoading.value : controller.isLoading.value;
      final error = isMyGigs ? controller.myGigsErrorMessage.value : controller.errorMessage.value;
      final list = isMyGigs ? controller.filteredMyGigs : controller.filteredGigs;

      if (loading) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 16.height),
          child: ShimmerLoading.list(
            itemCount: 4,
            height: 120.height,
            borderRadius: 12.radius,
          ),
        );
      }

      if (error.isNotEmpty && list.isEmpty) {
        return _GigErrorState(
          errorMessage: error,
          onRetry: isMyGigs ? controller.fetchMyGigs : controller.fetchAllGigs,
        );
      }

      if (list.isEmpty) {
        return _GigEmptyState(isMyGigs: isMyGigs);
      }

      return RefreshIndicator(
        onRefresh: isMyGigs ? controller.fetchMyGigs : controller.fetchAllGigs,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.width, vertical: 4.height),
          itemCount: list.length,
          itemBuilder: (context, index) => GigCard(
            gig: list[index],
            isMyGig: isMyGigs,
          ),
        ),
      );
    });
  }
}

class _GigErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _GigErrorState({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 60.fontSize,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16.height),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 14.fontSize, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20.height),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GigEmptyState extends StatelessWidget {
  final bool isMyGigs;
  const _GigEmptyState({this.isMyGigs = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 72.fontSize, color: Colors.grey.shade300),
          SizedBox(height: 16.height),
          Text(
            isMyGigs ? 'No posted gigs yet' : 'No gigs found',
            style: getTextStyle(
              fontSize: 18.fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 8.height),
          Text(
            isMyGigs
                ? 'Tap [+ Post New Gig] to start offering your services!'
                : 'Be the first to create a gig!',
            style: getTextStyle(fontSize: 14.fontSize, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
