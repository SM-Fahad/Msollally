import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/help_resource_model.dart';
import '../model/student_emergency_item_tab_model.dart';
import '../service/student_emergency_contact_service.dart';

class StudentEmergencyContactController extends GetxController {
  final StudentEmergencyContactService _service = StudentEmergencyContactService();

  var selectedTab = 0.obs;
  var resourcesList = <HelpResourceModel>[].obs;
  var isLoading = false.obs;
  var error = "".obs;

  late final List<StudentEmergencyItemTabModel> emergencyTab;

  @override
  void onInit() {
    super.onInit();
    
    emergencyTab = [
      StudentEmergencyItemTabModel(
        color: Colors.green.shade100,
        title: "Medical",
        icon: const Icon(Icons.medical_information, color: Colors.green),
        onTap: () {
          fetchResourcesForTab(0);
        },
      ),
      StudentEmergencyItemTabModel(
        title: "Fire",
        icon: const Icon(Icons.fire_extinguisher, color: Colors.blue),
        onTap: () {
          fetchResourcesForTab(1);
        },
        color: Colors.blue.shade100,
      ),
      StudentEmergencyItemTabModel(
        title: "Accident",
        icon: const Icon(Icons.emergency, color: Colors.red),
        onTap: () {
          fetchResourcesForTab(2);
        },
        color: Colors.red.shade100,
      ),
      StudentEmergencyItemTabModel(
        color: Colors.pink.shade100,
        title: "Natural disaster",
        icon: const Icon(Icons.nature_sharp, color: Colors.pink),
        onTap: () {
          fetchResourcesForTab(3);
        },
      ),
      StudentEmergencyItemTabModel(
        color: Colors.teal.shade100,
        title: "Rescue",
        icon: const Icon(Icons.help, color: Colors.teal),
        onTap: () {
          fetchResourcesForTab(4);
        },
      ),
      StudentEmergencyItemTabModel(
        color: Colors.orange.shade100,
        title: "Others",
        icon: const Icon(Icons.more_horiz, color: Colors.orange),
        onTap: () {
          fetchResourcesForTab(5);
        },
      ),
    ];

    // Load initial category (Medical)
    fetchResourcesForTab(0);
  }

  void fetchResourcesForTab(int index) async {
    String category = "";
    switch (index) {
      case 0:
        category = "medical";
        break;
      case 1:
        category = "fire";
        break;
      case 2:
        category = "accident";
        break;
      case 3:
        category = "disaster";
        break;
      case 4:
        category = "rescue";
        break;
      case 5:
        category = "others";
        break;
      default:
        category = "medical";
    }
    
    isLoading.value = true;
    error.value = "";
    try {
      final resources = await _service.fetchHelpResources(category: category);
      resourcesList.assignAll(resources);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

