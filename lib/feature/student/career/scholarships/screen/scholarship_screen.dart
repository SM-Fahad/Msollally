import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/scholarship_controller.dart';
import '../widgets/scholarship_tab_bar.dart';
import '../widgets/scholarship_list_view.dart';
import '../widgets/my_applications_view.dart';

class ScholarshipScreen extends StatelessWidget {
  const ScholarshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScholarshipController controller = Get.put(ScholarshipController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Scholarships',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              controller.fetchScholarships();
              controller.fetchMyApplications();
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          ScholarshipTabBar(controller: controller),
          Expanded(
            child: Obx(() {
              return controller.selectedTab.value == 0
                  ? ScholarshipListView(controller: controller)
                  : MyApplicationsView(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}
