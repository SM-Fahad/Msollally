import 'package:get/get.dart';
import 'package:msollaally/feature/student/career/find_jobs/controller/jobs.controller.dart';
import 'package:msollaally/feature/student/career/gigs/controller/gigs_controller.dart';
import 'package:msollaally/feature/student/career/scholarships/controller/scholarship_controller.dart';
import 'package:msollaally/feature/student/career/cv/screen/cv_screen.dart';

import '../model/my_career_model.dart';

class CareerController extends GetxController {
  var selectedTab = 0.obs;
  var progress = 0.obs;
  var profileCompleteness = 0.obs;
  var forYouItems = <CareerItem>[].obs;
  var isLoading = false.obs;

  late final JobController jobController;
  late final GigsController gigsController;
  late final ScholarshipController scholarshipController;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    
    // Initial calculation
    updateDynamicData();
    updateLoadingState();

    // Bind reactive listeners to update when data changes
    ever(jobController.myCvs, (_) => updateDynamicData());
    ever(jobController.allJobs, (_) => updateDynamicData());
    ever(gigsController.gigs, (_) => updateDynamicData());
    ever(scholarshipController.scholarships, (_) => updateDynamicData());

    ever(jobController.isLoading, (_) => updateLoadingState());
    ever(gigsController.isLoading, (_) => updateLoadingState());
    ever(scholarshipController.isLoading, (_) => updateLoadingState());
  }

  void _initControllers() {
    jobController = Get.isRegistered<JobController>()
        ? Get.find<JobController>()
        : Get.put(JobController());

    gigsController = Get.isRegistered<GigsController>()
        ? Get.find<GigsController>()
        : Get.put(GigsController());

    scholarshipController = Get.isRegistered<ScholarshipController>()
        ? Get.find<ScholarshipController>()
        : Get.put(ScholarshipController());
  }

  void updateLoadingState() {
    isLoading.value = jobController.isLoading.value ||
        gigsController.isLoading.value ||
        scholarshipController.isLoading.value;
  }

  void updateDynamicData() {
    int score = 0;
    
    // 1. Calculate preparation score
    // 40% if CV is uploaded
    if (jobController.myCvs.isNotEmpty) {
      score += 40;
    }
    
    // 20% each for exploring sections with active listings
    if (jobController.allJobs.isNotEmpty) {
      score += 20;
    }
    if (gigsController.gigs.isNotEmpty) {
      score += 20;
    }
    if (scholarshipController.scholarships.isNotEmpty) {
      score += 20;
    }
    
    progress.value = score;

    // 2. Calculate dynamic CV / profile completeness percentage
    if (jobController.myCvs.isEmpty) {
      profileCompleteness.value = 25; // Default basic completeness from basic account details
    } else {
      final cv = jobController.myCvs.first;
      int comp = 0;
      
      if ((cv['firstName'] as String?)?.isNotEmpty ?? false) comp += 10;
      if ((cv['lastName'] as String?)?.isNotEmpty ?? false) comp += 10;
      if ((cv['email'] as String?)?.isNotEmpty ?? false) comp += 10;
      if ((cv['mobileNo'] as String?)?.isNotEmpty ?? false) comp += 10;
      if ((cv['personalSummery'] as String?)?.isNotEmpty ?? false) comp += 20;
      if ((cv['contactAddress'] as String?)?.isNotEmpty ?? false) comp += 10;
      if ((cv['nationality'] as String?)?.isNotEmpty ?? false) comp += 10;
      
      final langs = cv['languageProficiency'];
      if (langs is List && langs.isNotEmpty) comp += 10;
      
      final hobbies = cv['hobbiesAndInterest'];
      if (hobbies is List && hobbies.isNotEmpty) comp += 10;
      
      profileCompleteness.value = comp.clamp(0, 100);
    }

    // 3. Generate dynamic recommendations list
    final List<CareerItem> items = [];

    if (jobController.myCvs.isEmpty) {
      items.add(CareerItem(
        title: "Build Your Professional CV",
        description: "A complete CV increases your chances of getting hired by 70%. Create yours now to stand out to top employers.",
        onTap: () {
          Get.to(() => CvScreen());
        },
      ));
    } else {
      items.add(CareerItem(
        title: "CV Builder Complete!",
        description: "Your CV is looking great! Keep it updated with your latest achievements to maximize your opportunities.",
        onTap: () {
          Get.to(() => CvScreen());
        },
      ));
    }

    if (jobController.allJobs.isNotEmpty) {
      items.add(CareerItem(
        title: "Explore ${jobController.allJobs.length} Job Openings",
        description: "We found ${jobController.allJobs.length} exciting job opportunities. Apply now to kickstart your professional journey.",
        onTap: () {
          selectedTab.value = 1; // Navigate to 'Find Jobs' tab
        },
      ));
    }

    if (gigsController.gigs.isNotEmpty) {
      items.add(CareerItem(
        title: "Earn via ${gigsController.gigs.length} Freelance Gigs",
        description: "Boost your income and gain real-world experience with ${gigsController.gigs.length} available gigs suited for you.",
        onTap: () {
          selectedTab.value = 2; // Navigate to 'Gigs' tab
        },
      ));
    }

    if (scholarshipController.scholarships.isNotEmpty) {
      items.add(CareerItem(
        title: "Find Funding in ${scholarshipController.scholarships.length} Scholarships",
        description: "Don't miss out on financial aid! Explore ${scholarshipController.scholarships.length} scholarship packages to support your academic goals.",
        onTap: () {
          selectedTab.value = 3; // Navigate to 'Scholarships' tab
        },
      ));
    }

    forYouItems.assignAll(items);
  }
}

