import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:msollaally/feature/auth/login/reset_password/screen/reset_otp_verify_screen.dart';
import 'package:msollaally/feature/auth/signup/account_opening/screens/account_login_activity.dart';
import 'package:msollaally/feature/auth/login/reset_password/screen/reset_screen.dart';
import 'package:msollaally/feature/auth/signup/account_opening/screens/basic_info.dart';
import 'package:msollaally/feature/furza_zone/screen/fursa_zone_screen.dart';
import 'package:msollaally/feature/furza_zone/student_quiz_competition/screen/main_screen/student_quiz_competition_screen.dart';
import 'package:msollaally/feature/pro_partners/more/change_password/screen/pro_partners_change_password_screen.dart';
import 'package:msollaally/feature/pro_partners/more/edit_name/screen/pro_partners_edit_name_screen.dart';
import 'package:msollaally/feature/pro_partners/more/profile/edit_profile/screen/pro_partners_edit_profile_screen.dart';
import 'package:msollaally/feature/pro_partners/more/profile/screen/pro_partners_profile_screen.dart';
import 'package:msollaally/feature/pro_partners/more/settings/screen/pro_partners_settings_screen.dart';
import 'package:msollaally/feature/pro_partners/pro_partners_nav/screen/pro_partners_nav_screen.dart';
import 'package:msollaally/feature/pro_partners/upgrade/screen/pro_partners_upgrade_screen.dart';
import 'package:msollaally/feature/pro_partners/fursa_zone/fusra_feed/screen/pro_partners_fursa_zone_screen.dart';
import 'package:msollaally/feature/recruiter/jobs/all_jobs/screen/all_jobs_screen.dart';
import 'package:msollaally/feature/recruiter/more/profile/edit_profile/screen/recruiter_edit_profile_screen.dart';
import 'package:msollaally/feature/recruiter/more/profile/screen/recruiter_profile_screen.dart';
import 'package:msollaally/feature/recruiter/more/change_password/screen/recruiter_change_password_screen.dart';
import 'package:msollaally/feature/recruiter/notification/screen/recruiter_notification_detail_screen.dart';
import 'package:msollaally/feature/recruiter/notification/screen/recruiter_notification_screen.dart';
import 'package:msollaally/feature/recruiter/recruiter_nav/screen/recruiter_nav_screen.dart';
import 'package:msollaally/feature/recruiter/more/settings/screen/recruiter_settings_screen.dart';
import 'package:msollaally/feature/student/calender/screen/student_calender_page.dart';
import 'package:msollaally/feature/student/campus/campus_home/widgets/qualification_quiz_screen.dart';
import 'package:msollaally/feature/student/campus/campus_student_public_profile/screen/student_campus_student_public_profile.dart'
    show StudentCampusStudentPublicProfilePage;
import 'package:msollaally/feature/student/converter/screen/student_file_converter_result_page.dart';
import 'package:msollaally/feature/student/profile/screen/student_profile_page.dart';
import 'package:msollaally/feature/student/referral_program/screen/referral_screen.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/basic_information/screen/academic_professional_info.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/basic_information/screen/teacher_basic_info_screen.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/basic_information/screen/upload_photo_and_bio.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/create_password_screen/screen/teacher_create_password_screen.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/otp_screen/screen/teacher_otp_screen.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/sign_up_screen/teacher_signUp_screen.dart';
import 'package:msollaally/feature/teacher/chat/screen/teacher_chat_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/screen/add_exam_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/screen/assesment_detaile_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/add_module_class_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/add_module_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/course_module_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/edit_module_class.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/teachers_class_detail_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/screen/course_notice_detail_screen.dart';

import 'package:msollaally/feature/teacher/courses/course_notices/screen/create_course_notice_screen.dart';

import 'package:msollaally/feature/teacher/courses/screen/teacher_add_course_screen.dart';
import 'package:msollaally/feature/teacher/notification/screen/teacher_notification_detail_screen.dart';
import 'package:msollaally/feature/teacher/notification/screen/teacher_notification_screen.dart';
import 'package:msollaally/feature/pro_partners/chat/screen/pro_partners_chat_screen.dart';
import 'package:msollaally/feature/pro_partners/chat/inbox/screen/pro_partners_inbox_screen.dart';
import 'package:msollaally/feature/teacher/profile/screen/teacher_edit_profile_name_screen.dart';
import 'package:msollaally/feature/teacher/profile/screen/teacher_profile_screen.dart';
import 'package:msollaally/feature/teacher/more/session/screen/teacher_session_screen.dart';
import 'package:msollaally/feature/teacher/schedule_classes/screen/teacher_schedule_class_screen.dart';
import 'package:msollaally/feature/teacher/teacher_nav/screen/teacher_nav_screen.dart';
import 'package:msollaally/feature/splash/splash.dart';
import '../feature/chooseProfile/screen/choose_profile_screen.dart';
import '../feature/recruiter/candidates/all_candidates/screen/all_candidates_screen.dart';
import '../feature/recruiter/candidates/candidate_details/screen/candidate_details_screen.dart';
import '../feature/student/create_task/screen/premium_payment_webview_screen.dart';
import '../feature/student/ai_chat/screen/student_ai_chat_page.dart';
import '../feature/student/ai_tips/screen/student_ai_tips_page.dart';
import '../feature/student/campus/campus_union/screen/student_union.dart';
import '../feature/student/campus/campaign/screen/campaign_detail_screen.dart';
import '../feature/student/campus/event/screen/event_detail_screen.dart';
import '../feature/student/campus/campus_union/screen/union_management_screen.dart';
import '../feature/student/campus/campus_union/screen/invite_friends_screen.dart';
import '../feature/student/campus/campus_inbox/screen/inbox_screen.dart';
import '../feature/student/campus/campus_union2/screen/student_union_2.dart';
import '../feature/student/converter/screen/student_file_converter_page.dart';
import '../feature/student/course_details_message/screen/student_course_details_msg_page.dart';
import '../feature/student/create_task/screen/student_create_task_upgrade.dart';
import '../feature/student/create_task/screen/student_task_details_page.dart';
import '../feature/student/create_task/edit_task/screen/student_task_edit_page.dart';
import '../feature/student/create_task/screen/student_task_list_page.dart';
import '../feature/student/create_task/screen/student_task_create_page.dart';
import '../feature/student/home/screen/student_home_screen.dart';
import '../feature/student/health_wellness/screen/health_screen.dart';
import '../feature/student/health_wellness/screen/wellness_screen.dart';
import '../feature/student/notification/screen/student_notification_page.dart';
import '../feature/student/notification/screen/student_notification_detail_screen.dart';
import '../feature/student/profile/screen/student_profile_edit_name_view.dart';
import '../feature/student/profile/screen/student_profile_edit_email_view.dart';
import '../feature/student/profile/screen/student_profile_edit_institution_view.dart';
import '../feature/student/profile/screen/student_profile_edit_student_id_view.dart';
import '../feature/student/profile/screen/student_profile_edit_bio_view.dart';
import '../feature/student/profile/screen/student_profile_edit_faculty_view.dart';
import '../feature/student/profile/screen/student_profile_edit_cell_view.dart';

// Student screens
import '../feature/student/academics/courses/academic_courses/screen/academics_screen.dart';
import '../feature/student/campus/campus_home/screen/student_campus_screen.dart';
import '../feature/student/career/my_career/screen/student_career_screen.dart';
import '../feature/student/more/screen/student_more_screen.dart';
import '../feature/student/search/screen/student_search_screen.dart';

// Teacher screens
import '../feature/student/settings/screen/student_settings_page.dart';
import '../feature/student/settings/screen/student_settings_edit_profile_screen.dart';

import '../feature/teacher/courses/screen/teacher_courses_screen.dart';
import '../feature/teacher/students/screen/teacher_students_screen.dart';
import '../feature/teacher/more/screen/teacher_more_screen.dart';

// Recruiter screens
import '../feature/recruiter/more/screen/recruiter_more_screen.dart';

// Pro Partners screens
import '../feature/pro_partners/dashboard/screen/pro_partners_dashboard_screen.dart';
import '../feature/pro_partners/campaign/all_campaigns/screen/all_campaigns_screen.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/screen/all_jobs_screen.dart';
import '../feature/pro_partners/more/screen/pro_partners_more_screen.dart';
import '../feature/pro_partners/help_support/screen/pro_partner_help_support_screen.dart';

import '../feature/terms_and_privacy/screen/terms_and_privacy_screen.dart';
import '../feature/feedback/screen/feedback_screen.dart';

// Authentication/Login Screens
import '../feature/auth/login/login_page/screen/loginScreen.dart';
import '../feature/auth/signup/signup_page/screen/signUpScreen.dart';
import '../feature/auth/login/otp/screen/otpScreen.dart';
import '../feature/auth/login/remove_device/screen/remove_screen.dart';

//SignUp Onboarding Screens
import '../feature/auth/signup/account_opening/screens/sign_up_screen_onboarding.dart';

class AppRoute {
  static String splashScreen = '/splash';
  static String chooseProfileScreen = '/choose_profile';

  static String resetOtpScreen = '/auth/reset_password/otp';

  // Student routes
  static String studentHomeScreen = '/student/home';
  static String studentAcademics = '/student/academics';
  static String studentCampus = '/student/campus';
  static String studentCareer = '/student/career';
  static String studentMore = '/student/more';
  static String studentGlobalSearch = '/student/global_search';

  // Teacher routes
  static String teacherHomeScreen = '/teacher/home';
  static String teacherCourses = '/teacher/courses';
  static String teacherStudents = '/teacher/students';
  static String teacherMore = '/teacher/more';
  static String teacherAddCourse = '/teacher/courses/add_course';
  static String teacherCourseModule = '/teacher/courses/course_module';
  static String teacherAddModuleScreen =
      '/teacher/courses/course_module/add_module';
  static String teacherProfileScreen = '/teacher/profile';
  static String teacherChatScreen = '/teacher/chat';
  static String teacherAddModuleClassScreen =
      '/teacher/courses/course_module/add_class';
  static String teacherClassDetailScreen =
      '/teacher/courses/course_module/class_detail';
  static String teacherAddAssesmentExamScreen =
      '/teacher/courses/course_assesment/add_exam';
  static String teacherAssesmentDetailScreen =
      '/teacher/courses/course_assesment/assesment_detail';
  static String teacherCreateCourseNoticeScreen =
      '/teacher/courses/course_notices/create_notice';
  static String teacherCourseNoticeDetailScreen =
      '/teacher/courses/course_notices/detail';
  static String teacherEditProfileNameScreen = '/teacher/profile/edit_name';
  static String teacherNotificationScreen = '/teacher/notification';
  static String teacherNotificationDetailScreen =
      '/teacher/notification/detail';
  static String teacherScheduleClassScreen = '/teacher/schedule_classes';
  static String teacherSessionScreen = '/teacher/more/session';
  static String editModuleClassScreen =
      '/teacher/courses/course_module/edit_class';
  //Teacher auth route
  static String teacherSignUpScreen = '/teacher/auth/signUp';
  static String teacherUploadPhotoScreen = '/teacher/auth/signUp/upload_photo';
  static String teacherOtpScreen = '/teacher/auth/signUp/otp';
  static String teacherCreatePasswordScreen =
      '/teacher/auth/signUp/createPassword';
  static String teacherBasicInfoScreen = '/teacher/auth/signUp/basic_info';
  static String teacherAcademicProfessionalInfoScreen =
      '/teacher/auth/signUp/academic_profesional_info';

  // Recruiter routes
  static String recruiterHomeScreen = '/recruiter/home';
  static String recruiterAllJobs = '/recruiter_all_jobs';
  static String recruiterAllCandidates = '/recruiter_all_Candidates';
  static String recruiterCandidateDetails = '/recruiter/candidate_details';
  static String recruiterMore = '/recruiter/more';
  static String recruiterSettingsScreen = '/recruiter/settings';
  static String recruiterEditProfileScreen = '/recruiter/edit_profile';
  static String recruiterProfileScreen = '/recruiter/recruiter_profile_screen';
  static String recruiterChangePasswordScreen = '/recruiter/change_password';

  static String recruiterNotificationScreen = '/recruiter/notification';
  static String recruiterNotificationDetailScreen =
      '/recruiter/notification/detail';

  // Pro Partners routes
  static String proPartnersDashboard = '/pro_partners_dashboard';
  static String proPartnersAllCampaigns = '/pro_partners_all_campaigns';
  static String proPartnersAllJobs = '/pro_partners_all_jobs';
  static String proPartnersNetwork = '/network';
  static String proPartnersMore = '/more';
  static String proPartnersProfile = '/pro_partners/profile';
  static String proPartnersSettings = '/pro_partners/settings';
  static String proPartnersEditName = '/pro_partners/profile/edit_name';
  static String proPartnersChangePassword = '/pro_partners/settings/password';
  static String proPartnersEditProfile = '/pro_partners/profile/edit';
  static String proPartnersUpgrade = '/pro_partners/upgrade';
  static String proPartnersFursaZone = '/pro_partners/fursa_zone';
  static String proPartnersHelpSupport = '/pro_partners/help_support';
  static String proPartnersChat = '/pro_partners/chat';
  static String proPartnersInbox = '/pro_partners/inbox';

  //Auth/Login Routes
  static String loginScreen = '/auth/login';
  static String loadingScreen = '/auth/loading';
  static String signUpScreen = '/auth/signup';
  static String otpScreen = '/auth/otp';
  static String removeScreen = '/auth/remove';
  static String createPass = '/auth/createPass';

  //SignUp Onboarding
  static String signUpScreenOnboarding = '/auth/onboarding';
  static String basicInfo = '/auth/basicInfo';
  static String accountLogInActivity = '/auth/accountLogInActivity';
  static String resetpassword = '/auth/resetPassword';

  //student home

  static String studentNotificationPage =
      '/student/home/notification'; //notification
  static String studentNotificationDetailPage =
      '/student/home/notification/detail';
  static String studentCalenderPage = '/student/home/calender'; //calender
  static String studentFileConverterPage =
      '/student/home/fileConverter'; //converter
  static String studentFileConverterResultPage =
      '/student/home/fileConverterResult'; //converted result

  static String studentAIChatpage = '/student/home/aichat'; //AI CHAt

  //task

  static String studentCreateTask = "/student/home/createTask";
  static String premiumPaymentWebview = "/student/home/premiumPaymentWebview";
  static String studentAllTaskList = "/student/home/allTaskList";
  static String studentEditTask = "/student/home/editTask";
  static String studentDetailsTask = "/student/home/detailsTask";

  static String studentSettingsEditProfileScreen =
      "/student/more/settings/edit_profile";

  // profile
  static String studentProfilePage = "/student/home/profile";
  static String studentProfileEditNameViewPage =
      "/student/home/profileEditNameView";
  static String studentProfileEditEmailViewPage =
      "/student/home/profileEditEmailView";
  static String studentProfileEditInstitutionViewPage =
      "/student/home/profileEditInstitutionView";
  static String studentProfileEditStudentIdViewPage =
      "/student/home/profileEditStudentIdView";
  static String studentProfileEditBioViewPage =
      "/student/home/profileEditBioView";
  static String studentProfileEditFacultyViewPage =
      "/student/home/profileEditFacultyView";
  static String studentProfileEditCellViewPage =
      "/student/home/profileEditCellView";
  static String studentAITipsPage = "/student/home/aiTips";

  //student settings

  static String studentSettings = "/student/more/settings";
  static String studentupgrade = "/student/more/upgrade";

  //student course details message
  static String studentCourseDetailsMsg = "/student/home/courseDetailsMsg";

  //student/campus
  static String studentCampusPublicProfile = "/student/campus/publicProfile";

  static String studentCampusInbox = "/student/campus/inbox";
  static String studentCampusUnion = "/student/campus/union";
  static String studentCampusUnion2 = "/student/campus/union2";
  static String unionManagementScreen = "/student/campus/union/manage";
  static String inviteFriendsScreen = "/student/campus/union/invite-friends";
  static String studentCampusCampaignDetail = "/student/campus/campaign/detail";
  static String studentCampusEventDetail = "/student/campus/event/detail";

  //student more health and wellness and emergency contact
  static String studentHealthScreen = "/student/more/health";
  static String studentWellnessScreen = "/student/more/wellness";
  static String fursaZoneScreen = "/fursaZoneScreen";
  static String studentQuizCompetition = "/studentQuizCompetition";
  static String studentMentalHealthResources = "/student/more/mental-health";
  static String studentEmergencySupport = "/student/more/emergency-support";
  static String studentPhysicalHealthResources = "/student/more/physical-health";

  // Referral Programme

  static String referralScreen = '/referralprogram';
  static String qualificationQuizScreen = '/qualificationQuizScreen';
  static String termsAndPrivacyScreen = '/terms_and_privacy';
  static String feedbackScreen = '/feedback';

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: chooseProfileScreen, page: () => ChooseProfileScreen()),

    GetPage(name: resetOtpScreen, page: () => ResetOtpVerifyScreen()),

    // Home screens with integrated navbar
    GetPage(name: studentHomeScreen, page: () => StudentHomeScreen()),
    GetPage(name: teacherHomeScreen, page: () => TeacherNavScreen()),
    GetPage(name: recruiterHomeScreen, page: () => RecruiterNavScreen()),
    GetPage(name: proPartnersDashboard, page: () => ProPartnersNavScreen()),

    // Student screens
    GetPage(name: studentAcademics, page: () => StudentAcademicsScreen()),
    GetPage(name: studentCampus, page: () => StudentCampusScreen()),
    GetPage(name: studentCareer, page: () => StudentCareerScreen()),
    GetPage(name: studentMore, page: () => StudentMoreScreen()),

    // Teacher screens
    GetPage(name: teacherCourses, page: () => TeacherCoursesScreen()),
    GetPage(name: teacherStudents, page: () => TeacherStudentsScreen()),
    GetPage(name: teacherMore, page: () => TeacherMoreScreen()),
    GetPage(name: teacherAddCourse, page: () => TeacherAddCourseScreen()),
    GetPage(name: teacherCourseModule, page: () => CourseModuleScreen()),
    GetPage(name: teacherAddModuleScreen, page: () => TeacherAddModuleScreen()),
    GetPage(name: teacherProfileScreen, page: () => TeacherProfileScreen()),
    GetPage(name: teacherChatScreen, page: () => TeacherChatScreen()),
    GetPage(
      name: teacherAddModuleClassScreen,
      page: () => AddModuleClassScreen(),
    ),
    GetPage(
      name: teacherClassDetailScreen,
      page: () => TeachersClassDetailScreen(),
    ),
    GetPage(
      name: teacherAddAssesmentExamScreen,
      page: () => AddAssesmentExamScreen(),
    ),
    GetPage(
      name: teacherAssesmentDetailScreen,
      page: () => TeachersAssesmentDetailScreen(),
    ),
    GetPage(
      name: teacherCreateCourseNoticeScreen,
      page: () => CreateCourseNoticeScreen(),
    ),
    GetPage(
      name: teacherCourseNoticeDetailScreen,
      page: () => CourseNoticeDetailScreen(),
    ),
    GetPage(
      name: teacherEditProfileNameScreen,
      page: () => TeacherEditProfileNameScreen(),
    ),
    GetPage(
      name: teacherNotificationScreen,
      page: () => TeacherNotificationScreen(),
    ),
    GetPage(
      name: teacherNotificationDetailScreen,
      page: () => TeacherNotificationDetailScreen(),
    ),
    GetPage(
      name: teacherScheduleClassScreen,
      page: () => TeacherScheduleClassScreen(),
    ),
    GetPage(name: teacherSessionScreen, page: () => TeacherSessionScreen()),
    GetPage(name: editModuleClassScreen, page: () => EditModuleClassScreen()),

    GetPage(name: teacherSignUpScreen, page: () => TeacherSignUpScreen()),
    GetPage(
      name: teacherUploadPhotoScreen,
      page: () => TeacherUploadPhotoScreen(),
    ),
    GetPage(name: teacherOtpScreen, page: () => TeacherOtpScreen()),
    GetPage(
      name: teacherCreatePasswordScreen,
      page: () => TeacherCreatePasswordScreen(),
    ),
    GetPage(name: teacherBasicInfoScreen, page: () => TeacherBasicInfoScreen()),
    GetPage(
      name: teacherAcademicProfessionalInfoScreen,
      page: () => TeacherAcademicProfessionalInfo(),
    ),

    // Recruiter screens
    GetPage(name: recruiterAllJobs, page: () => RecruiterAllJobsScreen()),
    GetPage(
      name: recruiterAllCandidates,
      page: () => RecruiterAllCandidatesScreen(),
    ),
    GetPage(
      name: recruiterCandidateDetails,
      page: () => CandidateDetailsScreen(),
    ),
    GetPage(name: recruiterMore, page: () => RecruiterMoreScreen()),
    GetPage(
      name: recruiterSettingsScreen,
      page: () => RecruiterSettingsScreen(),
    ),
    GetPage(
      name: recruiterEditProfileScreen,
      page: () => RecruiterEditProfileScreen(),
    ),
    GetPage(name: recruiterProfileScreen, page: () => RecruiterProfileScreen()),
    GetPage(
      name: recruiterChangePasswordScreen,
      page: () => RecruiterChangePasswordScreen(),
    ),

    GetPage(
      name: recruiterNotificationScreen,
      page: () => RecruiterNotificationScreen(),
    ),
    GetPage(
      name: recruiterNotificationDetailScreen,
      page: () => RecruiterNotificationDetailScreen(),
    ),

    // Pro Partners screens
    GetPage(
      name: proPartnersDashboard,
      page: () => ProPartnersDashboardScreen(),
    ),
    GetPage(
      name: proPartnersAllCampaigns,
      page: () => ProPartnersAllCampaignsScreen(),
    ),
    GetPage(name: proPartnersAllJobs, page: () => ProPartnersAllJobsScreen()),
    GetPage(name: proPartnersMore, page: () => ProPartnersMoreScreen()),
    GetPage(name: proPartnersProfile, page: () => ProPartnersProfileScreen()),
    GetPage(name: proPartnersSettings, page: () => ProPartnersSettingsScreen()),
    GetPage(name: proPartnersEditName, page: () => ProPartnersEditNameScreen()),
    GetPage(
      name: proPartnersChangePassword,
      page: () => ProPartnersChangePasswordScreen(),
    ),
    GetPage(
      name: proPartnersEditProfile,
      page: () => ProPartnersEditProfileScreen(),
    ),
    GetPage(name: proPartnersUpgrade, page: () => ProPartnersUpgradeScreen()),
    GetPage(
      name: proPartnersFursaZone,
      page: () => ProPartnersFursaZoneScreen(),
    ),
    GetPage(
      name: proPartnersHelpSupport,
      page: () => const ProPartnerHelpSupportScreen(),
    ),
    GetPage(
      name: proPartnersChat,
      page: () => ProPartnersChatScreen(),
    ),
    GetPage(
      name: proPartnersInbox,
      page: () => const ProPartnersInboxScreen(),
    ),

    // Auth/Login screens
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: signUpScreen, page: () => SignUpScreen()),
    GetPage(name: otpScreen, page: () => OtpScreen()),
    // GetPage(name: createPass, page: () => CreatePass()),
    GetPage(name: removeScreen, page: () => RemoveScreen()),

    GetPage(name: resetpassword, page: () => ResetPasswordScreen()),

    //SignUp Onboarding Screens
    GetPage(name: signUpScreenOnboarding, page: () => SignUpScreenOnboarding()),
    GetPage(name: basicInfo, page: () => BasicInfoScreen()),
    GetPage(name: accountLogInActivity, page: () => AccountLogInActivity()),
    GetPage(name: removeScreen, page: () => RemoveScreen()),

    //student home
    GetPage(
      name: studentNotificationPage,
      page: () => StudentNotificationPage(),
    ),
    GetPage(
      name: studentNotificationDetailPage,
      page: () => StudentNotificationDetailScreen(),
    ),
    GetPage(name: studentCalenderPage, page: () => StudentCalenderPage()),
    GetPage(name: studentGlobalSearch, page: () => const StudentSearchScreen()),

    //converter
    GetPage(
      name: studentFileConverterPage,
      page: () => StudentFileConverterPage(),
    ),

    GetPage(
      name: studentFileConverterResultPage,
      page: () => StudentFileConverterResultPage(),
    ),

    //ai chat
    GetPage(name: studentAIChatpage, page: () => StudentAIChatPage()),
    GetPage(name: studentCreateTask, page: () => StudentCreateTaskPage()),
    GetPage(name: premiumPaymentWebview, page: () => PremiumPaymentWebviewScreen()),

    //Create a Task
    GetPage(name: studentAllTaskList, page: () => StudentAllTaskList()),
    GetPage(name: studentEditTask, page: () => StudentEditTaskPage()),
    GetPage(name: studentDetailsTask, page: () => StudentTaskDetailsPage()),
    //profile
    GetPage(name: studentProfilePage, page: () => StudentProfilePage()),
    GetPage(
      name: studentProfileEditNameViewPage,
      page: () => StudentProfileEditNameView(),
    ),
    GetPage(
      name: studentProfileEditEmailViewPage,
      page: () => StudentProfileEditEmailView(),
    ),
    GetPage(
      name: studentProfileEditInstitutionViewPage,
      page: () => StudentProfileEditInstitutionView(),
    ),
    GetPage(
      name: studentProfileEditStudentIdViewPage,
      page: () => StudentProfileEditStudentIdView(),
    ),
    GetPage(
      name: studentProfileEditBioViewPage,
      page: () => StudentProfileEditBioView(),
    ),
    GetPage(
      name: studentProfileEditFacultyViewPage,
      page: () => StudentProfileEditFacultyView(),
    ),
    GetPage(
      name: studentProfileEditCellViewPage,
      page: () => StudentProfileEditCellView(),
    ),
    //ai tips
    GetPage(name: studentAITipsPage, page: () => StudentAiTipsPage()),

    //student settings
    GetPage(name: studentSettings, page: () => StudentSettingsPage()),
    GetPage(
      name: studentSettingsEditProfileScreen,
      page: () => StudentSettingsEditProfileScreen(),
    ),

    GetPage(name: studentupgrade, page: () => StudentCreateTaskUpgrade()),

    GetPage(
      name: studentCourseDetailsMsg,
      page: () => StudentCourseDetailsMsg(),
    ),

    //student / campus
    GetPage(
      name: studentCampusPublicProfile,
      page: () => StudentCampusStudentPublicProfilePage(),
    ),

    GetPage(name: studentCampusInbox, page: () => InboxScreen()),



    //student union
    GetPage(name: studentCampusUnion, page: () => StudentUnion()),
    GetPage(name: studentCampusUnion2, page: () => StudentUnion2()),
    GetPage(name: unionManagementScreen, page: () => UnionManagementScreen()),
    GetPage(name: inviteFriendsScreen, page: () => InviteFriendsScreen()),
    GetPage(
      name: studentCampusCampaignDetail,
      page: () => const CampaignDetailScreen(),
    ),
    GetPage(
      name: studentCampusEventDetail,
      page: () => const EventDetailScreen(),
    ),

    //sruden/////more health and wellness and emergency contact
    GetPage(
      name: studentHealthScreen,
      page: () => StudentHealthScreen(),
    ),
    GetPage(
      name: studentWellnessScreen,
      page: () => StudentWellnessScreen(),
    ),
    GetPage(name: fursaZoneScreen, page: () => FursaZoneScreen()),
    GetPage(name: studentQuizCompetition, page: () => StudentQuizCompetition()),
    GetPage(name: referralScreen, page: () => ReferralScreen()),
    GetPage(
      name: qualificationQuizScreen,
      page: () => QualificationQuizScreen(),
    ),
    GetPage(
      name: termsAndPrivacyScreen,
      page: () => const TermsAndPrivacyScreen(),
    ),
    GetPage(
      name: feedbackScreen,
      page: () => FeedbackScreen(),
    ),
  ];
}
