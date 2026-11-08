import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../controller/gigs_controller.dart';
import '../model/gigs_model.dart';
import '../widgets/gig_detail/gig_detail_action_menu.dart';
import '../widgets/gig_detail/gig_detail_card.dart';

class GigDetailScreen extends StatelessWidget {
  const GigDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gig = Get.arguments as GigsModel?;

    if (gig == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gig Details')),
        body: const Center(child: Text('No gig data available.')),
      );
    }

    final controller = Get.isRegistered<GigsController>()
        ? Get.find<GigsController>()
        : Get.put(GigsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gig Details'),
        actions: [GigDetailActionMenu(controller: controller, gig: gig)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.width),
        child: GigDetailCard(gig: gig),
      ),
    );
  }
}
