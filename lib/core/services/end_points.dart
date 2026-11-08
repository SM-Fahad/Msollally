class Urls {
  // static const String baseUrl = 'https://episode-watt-participants-allows.trycloudflare.com';
  static const String baseUrl = 'https://api.nodmac.com';
  static const String socketUrl = 'https://api.nodmac.com/chat';
  static const String aiChatSocketUrl = 'https://api.nodmac.com/ai-chat';

  static const String posts = '$baseUrl/posts';
  static String postById(int id) => '$baseUrl/posts/$id';
  static String likePost(int id) => '$baseUrl/posts/$id/like';
  static String unlikePost(int id) => '$baseUrl/posts/$id/unlike';

  // Comment Endpoints
  static String createCommentOrReply(int postId) => '$baseUrl/comments/$postId';
  static String getCommentsForPost(int postId) =>
      '$baseUrl/comments/post/$postId';
  static String likeComment(int commentId) =>
      '$baseUrl/comments/$commentId/like';
  static String unlikeComment(int commentId) =>
      '$baseUrl/comments/$commentId/unlike';
  static String deleteComment(int commentId) => '$baseUrl/comments/$commentId';

  // Auth Endpoints
  static const String signUp = '$baseUrl/auth/signup';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String setPassword = '$baseUrl/auth/password/set';
  static const String resetPassword = "$baseUrl/auth/password/reset";
  static const String changePassword = '$baseUrl/auth/password/change';
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String authMe = '$baseUrl/auth/me';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String profileUpdate = '$baseUrl/profile/update';
  static const String profile = '$baseUrl/auth/profile/complete';
  static const String changePrivacySettings =
      '$baseUrl/profile/change-privacy-settings';
  static const String sessions = '$baseUrl/auth/sessions';
  static String sessionById(int id) => '$baseUrl/auth/sessions/$id';
  static String profilePublicById(String id) => '$baseUrl/profile/public/$id';
  static const String createTask = '$baseUrl/tasks/create';
  static const String notifications = '$baseUrl/notifications';
  static const String notificationsUnreadCount =
      '$baseUrl/notifications/unread-count';
  static const String notificationPreferences =
      '$baseUrl/notifications/preferences';
  static const String notificationPreferencesMe =
      '$baseUrl/notifications/preferences/me';
  static String notificationById(int id) => '$baseUrl/notifications/$id';
  static String markNotificationRead(int id) =>
      '$baseUrl/notifications/$id/read';
  static String archiveNotification(int id) =>
      '$baseUrl/notifications/$id/archive';
  static const String markAllNotificationsRead =
      '$baseUrl/notifications/mark-all-read';
  static const String uploadFile = '$baseUrl/files/upload';
  static const String uploadCloudinaryFile = '$baseUrl/files/cloudinary/upload';
  static const String convertUpload = '$baseUrl/convert/upload';
  static const String getAllTasks = '$baseUrl/tasks/all';
  static String getAllPlans(String id) =>
      '$aiChatBaseUrl/create/plans/user/$id';
  static const String deleteTask = '$baseUrl/tasks/delete';
  static const String markTaskCompletedTasks = '$baseUrl/tasks/mark-completed';
  static String getTaskById(int id) => '$baseUrl/tasks/$id';
  static String getPlanById(String id) => '$aiChatBaseUrl/create/plans/$id';
  static String deleteTaskById(int id) => '$baseUrl/tasks/delete/$id';
  static String isFavoriteTaskById(int id) => '$baseUrl/tasks/isfavorite/$id';
  static String convertFileById(int id) => '$baseUrl/convert/$id';

  // Gig Endpoints
  static const String createGig = '$baseUrl/gig/create';
  static const String getAllGigs = '$baseUrl/gig/all';
  static const String getMyGigs = '$baseUrl/gig/my-gigs';
  static String getGigById(int id) => '$baseUrl/gig/$id';
  static String updateGigById(int id) => '$baseUrl/gig/$id';
  static String deleteGigById(int id) => '$baseUrl/gig/$id';

  // Jobs Endpoints
  static const String jobs = '$baseUrl/jobs';
  static String jobById(int id) => '$baseUrl/jobs/$id';
  static String applyJob(int id) => '$baseUrl/jobs/$id/apply';
  static String updateJobById(int id) => '$baseUrl/jobs/$id';
  static const String myJobApplications = '$baseUrl/jobs/applications/my';
  static String jobApplicationById(int id) =>
      '$baseUrl/jobs/applications/$id';
  static String withdrawJobApplication(int id) =>
      '$baseUrl/jobs/applications/$id';

  // CV Endpoints
  static const String createCv = '$baseUrl/cv/create';
  static const String getAllCv = '$baseUrl/cv/all';
  static const String deleteCv = '$baseUrl/cv/delete';
  static String getCvById(String id) => '$baseUrl/cv/$id';
  static String updateCvById(String id) => '$baseUrl/cv/update/$id';
  static String downloadCv(String id) => '$baseUrl/cv/download/$id';

  // AI Chat
  static const String aiChatBaseUrl = 'http://148.230.123.203:8000';
  static const String aiChat = '$aiChatBaseUrl/chat';
  static const String createAiPlan = '$aiChatBaseUrl/create/plans/create';

  // Scholarships Endpoints
  static const String scholarships = '$baseUrl/scholarship/user/all';
  static String applyScholarship(int id) => '$baseUrl/scholarship/apply/$id';
  static const String myScholarshipApplications =
      '$baseUrl/scholarship/application/me';
  static String updateScholarshipApplication(int id) =>
      '$baseUrl/scholarship/application/update/$id';
  static String getScholarshipApplicationById(int id) =>
      '$baseUrl/scholarship/application/$id';

  // Library
  static const String libraryBooks = '$baseUrl/library/books';
  static String bookById(String id) => '$baseUrl/library/books/$id';

  // Question Bank
  static const String questionBank = '$baseUrl/question-bank';
  static String questionBankById(String id) => '$baseUrl/question-bank/$id';
  static String practiceQuestions(String qbankId) =>
      '$baseUrl/question-bank/$qbankId/practice-questions';
  static String practiceQuestionsSubmit(String qbankId) =>
      '$baseUrl/question-bank/$qbankId/practice-questions/submit';
  static String practiceQuestionById(String questionId) =>
      '$baseUrl/question-bank/question/$questionId';

  // Help & Rescue Resources
  static const String helpResources = '$baseUrl/help-resources';
  static const String helpResourceCategories =
      '$baseUrl/help-resources/categories';

  // Courses
  static const String myEnrolledCourses = '$baseUrl/courses/myEnrollCourse';
  static const String courseList = '$baseUrl/courses';
  static const String myCourses = '$baseUrl/courses/my-courses';
  static const String instructorDashboard =
      '$baseUrl/courses/dashboard/instructor';
  static const String studentDashboard = '$baseUrl/courses/dashboard/student';
  static String courseById(int courseId) => '$baseUrl/courses/$courseId';
  static String enrollCourse(int courseId) =>
      '$baseUrl/courses/$courseId/enroll';
  static String dropCourse(int courseId) => '$baseUrl/courses/$courseId/drop';
  static String myCourseProgress(int courseId) =>
      '$baseUrl/courses/my-progress/$courseId';
  static String publishCourse(int courseId) =>
      '$baseUrl/courses/$courseId/publish';
  static String cloneCourse(int courseId) => '$baseUrl/courses/$courseId/clone';
  static String courseModules(int courseId) =>
      '$baseUrl/courses/$courseId/modules';
  static String moduleDetails(int moduleId) =>
      '$baseUrl/courses/modules/$moduleId';

  static String moduleById(int moduleId) =>
      '$baseUrl/courses/modules/$moduleId';
  static String moduleProgress(int moduleId) =>
      '$baseUrl/courses/modules/$moduleId/progress';
  static String moduleClasses(int moduleId) =>
      '$baseUrl/courses/modules/$moduleId/classes';
  static String moduleFiles(int moduleId) =>
      '$baseUrl/courses/modules/$moduleId/files';
  static String moduleFileById(int fileId) =>
      '$baseUrl/courses/module-files/$fileId';
  static String classById(int classId) => '$baseUrl/courses/classes/$classId';
  static String classFiles(int classId) =>
      '$baseUrl/courses/classes/$classId/files';
  static String courseNotices(int courseId) =>
      '$baseUrl/courses/$courseId/notices';
  static String courseStudents(int courseId) =>
      '$baseUrl/courses/$courseId/students';
  static const String facultyMyStudents =
      '$baseUrl/courses/faculty/my-students';
  static String courseGroups(int courseId) =>
      '$baseUrl/courses/$courseId/groups';
  static String courseGroupById(int groupId) =>
      '$baseUrl/courses/groups/$groupId';
  static String courseAssessments(int courseId) =>
      '$baseUrl/courses/$courseId/assessments';
  static String assessmentById(int assessmentId) =>
      '$baseUrl/courses/assessments/$assessmentId';
  static String submitAssessment(int assessmentId) =>
      '$baseUrl/courses/assessments/$assessmentId/submit';
  static String assessmentFiles(int assessmentId) =>
      '$baseUrl/courses/assessments/$assessmentId/files';
  static String assessmentMySubmission(int assessmentId) =>
      '$baseUrl/courses/assessments/$assessmentId/my-submission';
  static String assessmentSubmissions(int assessmentId) =>
      '$baseUrl/courses/assessments/$assessmentId/submissions';
  static String gradeCourseSubmission(int submissionId) =>
      '$baseUrl/courses/submissions/$submissionId/grade';
  static String courseMySubmissions(int courseId) =>
      '$baseUrl/courses/$courseId/my-submissions';
  static String courseNoticeById(int noticeId) =>
      '$baseUrl/courses/notices/$noticeId';

  // Class Representative (CR) Endpoints
  static const String myCrCourses = '$baseUrl/courses/my-cr-courses';
  static String courseCrs(int courseId) => '$baseUrl/courses/$courseId/cr';
  static String courseCrById(int courseId, int studentId) =>
      '$baseUrl/courses/$courseId/cr/$studentId';

  // Friendship Endpoints
  static const String friendSuggestions = '$baseUrl/friendships/suggestions';
  static const String sendFriendRequest = '$baseUrl/friendships/request';
  static const String acceptFriendRequest = '$baseUrl/friendships/accept';
  static const String rejectFriendRequest = '$baseUrl/friendships/reject';
  static String mutualFriends(int id) => '$baseUrl/friendships/mutual/$id';
  static String friendsByUniversity(int id) =>
      '$baseUrl/friendships/university/$id';
  static const String pendingFriendRequests = '$baseUrl/friendships/pending';
  static const String friends = '$baseUrl/friendships/friends';
  static const String removeFriend = '$baseUrl/friendships/remove';

  // Pro-Partner
  static const String createCampaign = '$baseUrl/campaigns/create';
  static String updateCampaign(String campaignId) =>
      "$baseUrl/campaign/$campaignId";
  static String deleteCampaign(String campaignId) =>
      "$baseUrl/campaign/$campaignId";
  static String updateCampaignStatus(String campaignId, String status) =>
      "$baseUrl/campaigns/status/$campaignId?status=$status";
  static String getCampaign(String campaignId) =>
      "$baseUrl/campaigns/details/$campaignId";
  static String getAllCampaigns({int page = 1, int limit = 10}) =>
      '$baseUrl/campaigns/feed/me?page=$page&limit=$limit';
  static String countCampaignViews(int id) => '$baseUrl/campaigns/$id/view';
  static String countCampaignImpressions(int id) =>
      '$baseUrl/campaigns/$id/impression';
  static String getCampaignStats(String id) => "$baseUrl/campaigns/$id/stats";
  static String postNotice(String campaignId) =>
      "$baseUrl/campaigns/$campaignId/notices";
  static String getNotice(String campaignId) =>
      "$baseUrl/campaigns/$campaignId/notices";
  static String updateNotice(String noticeId) =>
      "$baseUrl/campaigns/notices/$noticeId";
  static String campaignLike(String id) => "$baseUrl/campaigns/$id/like";
  static String campaignDisLike(String id) => "$baseUrl/campaigns/$id/unlike";
  static String campaignComment(String id) => "$baseUrl/campaigns/$id/comment";
  // ----------------------------------------------
  static const String createJob = '$baseUrl/jobs';
  static String getMyJobs(String status) =>
      '$baseUrl/jobs/my-posted?status=$status';
  static String getJob(String id) => '$baseUrl/jobs/$id';
  static String getJobById(String jobId) => '$baseUrl/jobs/$jobId';
  static String getJobView(String id) => '$baseUrl/jobs/$id/view';
  static String getJobStatus(String id) =>
      '$baseUrl/jobs/$id/applications/stats';
  static String getJobApplicants(String id) => '$baseUrl/jobs/$id/applications';
  static String updateJobForApplicants(String id) =>
      '$baseUrl/jobs/applications/$id/status';
  static String getAllRecruiterCandidates(int page, int limit) =>
      '$baseUrl/jobs/applications?status=pending&page=$page&limit=$limit';
  static String updateJobStatus(String id) => "$baseUrl/jobs/$id/status";
  static String updateOrdeleteAJob(String jobId) => "$baseUrl/jobs/$jobId";
  // -------------------------------------------------------
  static const String overviewOfProPartner = '$baseUrl/pro-partner/stats';
  // -------------------------------------------------------
  static const String createEvent = "$baseUrl/events";
  static String getEventById(String eventId) => "$baseUrl/events/$eventId";
  static String updateEvent(String eventId) => "$baseUrl/events/$eventId";
  static String deleteEvent(String eventId) => "$baseUrl/events/$eventId";
  static const String searchCoHost = "$baseUrl/users";
  static String getEventAnalyticById(int id) => '$baseUrl/events/$id/analytics';
  static const String getMyEvent = '$baseUrl/events/my-events';
  static String getEventAttendees(String eventId, String status) =>
      status.isEmpty
      ? "$baseUrl/events/$eventId/attendees"
      : "$baseUrl/events/$eventId/attendees?status=$status";

  static String updateStatusForAttendee(String eventID, String attendeeID) =>
      "$baseUrl/events/$eventID/attendees/$attendeeID/status";
  static String eventLike(String id) => "$baseUrl/events/$id/like";
  static String eventDisLike(String id) => "$baseUrl/events/$id/unlike";
  static String eventComment(String id) => "$baseUrl/events/$id/comment";
  static String eventView(int id) => "$baseUrl/events/$id/view";
  static String eventCheckIn(int id) => "$baseUrl/events/$id/check-in";

  // ------------------------------------------------------------
  static String getProFusraFeed({int page = 1, int limit = 10}) =>
      '$baseUrl/competitions/pro/all/feed?page=$page&limit=$limit';
  static String getFursaDetails(String id) => "$baseUrl/competitions/$id";
  static String getCompetitionStats(String id) =>
      "$baseUrl/competitions/$id/stats";
  static String getTopSchoolPerform(String id) =>
      "$baseUrl/winners/top-schools/$id";
  static String getRegistrations({
    required String competitionId,
    String search = '',
    int page = 1,
    int limit = 5,
  }) =>
      "$baseUrl/registrations/leaderboard/$competitionId?search=$search&page=$page&limit=$limit";
  static String getExportCSV(String competitionId) =>
      "$baseUrl/registrations/export/csv/$competitionId";
  static String getExportExcel(String competitionId) =>
      "$baseUrl/registrations/export/excel/$competitionId";
  // Universities
  static const String getUniversities = '$baseUrl/universities';
  static String getProgramsByUniversity(int id) =>
      '$baseUrl/universities/programs/$id';
  static String getDepartmentsByProgram(int id) =>
      '$baseUrl/universities/departments/$id';

  // Interview Topics
  static const String getInterviewTopics = '$baseUrl/interview/topics';
  static String getInterviewTopic(String id) => '$baseUrl/interview/topics/$id';
  static String submitInterviewTopic(String id) => '$baseUrl/interview/topics/$id/submit';

  // Union Endpoints
  static const String unions = '$baseUrl/unions';
  static String unionById(int id) => '$baseUrl/unions/$id';
  static String updateUnion(int id) => '$baseUrl/unions/$id';
  static String deleteUnion(int id) => '$baseUrl/unions/$id';
  static String joinUnion(int id) => '$baseUrl/unions/$id/join';
  static String leaveUnion(int id) => '$baseUrl/unions/$id/leave';
  static String unionMembers(int id) => '$baseUrl/unions/$id/members';
  static String unionOfficials(int id) => '$baseUrl/unions/$id/officials';
  static String unionPendingRequests(int id) =>
      '$baseUrl/unions/$id/pending-requests';
  static String approveUnionMember(int id, int memberId) =>
      '$baseUrl/unions/$id/members/$memberId/approve';
  static String rejectUnionMember(int id, int memberId) =>
      '$baseUrl/unions/$id/members/$memberId/reject';
  static String updateMemberRole(int id, int memberId) =>
      '$baseUrl/unions/$id/members/$memberId/role';
  static String removeUnionMember(int id, int memberId) =>
      '$baseUrl/unions/$id/members/$memberId';
  static String unionStats(int id) => '$baseUrl/unions/$id/stats';
  static String transferPresidency(int id) =>
      '$baseUrl/unions/$id/transfer-presidency';
  static String inviteMember(int id, int memberId) =>
      '$baseUrl/unions/$id/members/$memberId/invite';
  static const String viewInvitations = '$baseUrl/unions/view-invitations';
  static String acceptInvite(int id) => '$baseUrl/unions/$id/accept-invite';

  // Pro-Partner Endpoints
  static const String proPartnersProfile = '$baseUrl/';

  // Users
  static String userById(int id) => '$baseUrl/users/$id';

  // Competitions
  static const String getAllCompetitions = '$baseUrl/competitions';
  static const String getActiveCompetitions = '$baseUrl/competitions/active';
  static String getCompetitionById(int id) => '$baseUrl/competitions/$id';
  static const String recordLearningProgress =
      '$baseUrl/learning-progress/record';
  static String getLearningProgress(int registrationId) =>
      '$baseUrl/learning-progress/user/$registrationId';

  static const String addLearningCoins =
      '$baseUrl/registrations/learning-coins';
  static const String addQuizCoins = '$baseUrl/registrations/add-coins';
  static const String updateQualification =
      '$baseUrl/registrations/qualification';
  static const String submitQuizResult = '$baseUrl/quiz-results/submit';
  static String getLeaderboard({
    required int competitionId,
    required String filter,
  }) => '$baseUrl/quiz-results/leaderboard/$competitionId?filter=$filter';
  static String getUserRank({
    required int userId,
    required int competitionId,
    required String filter,
  }) => '$baseUrl/quiz-results/rank/$userId/$competitionId?filter=$filter';
  static String getQuizHistory({
    required int userId,
    required int competitionId,
  }) => '$baseUrl/quiz-results/history/$userId/$competitionId';
  static const String claimBonus = '$baseUrl/competitions/bonus/claim';
  static const String bonusCheckIn = '$baseUrl/competitions/bonus/check-in';
  static String getBonusStatus(int competitionId) =>
      '$baseUrl/competitions/bonus/status/$competitionId';
  static String getQuizQuestions({
    required int competitionId,
    required String quizType,
    required int weekNumber,
  }) =>
      '$baseUrl/quiz-csv/questions-student/$competitionId?quizType=$quizType&weekNumber=$weekNumber';
  static String getAdminQuizQuestions({
    required int competitionId,
    required String quizType,
    required int weekNumber,
  }) =>
      '$baseUrl/quiz-csv/questions/$competitionId?quizType=$quizType&weekNumber=$weekNumber';

  // Winners & Top Schools
  static String lastWeekWinners(int competitionId) =>
      '$baseUrl/winners/last-week/$competitionId';
  static String thisWeekWinners(int competitionId) =>
      '$baseUrl/winners/this-week/$competitionId';
  static String topSchools(int competitionId) =>
      '$baseUrl/winners/top-schools/$competitionId';
  static String adminPerformance(int competitionId) =>
      '$baseUrl/winners/admin/performance/$competitionId';
  static String adminQualifiers(int competitionId) =>
      '$baseUrl/winners/admin/qualifiers/$competitionId';
  static String adminParticipants(int competitionId) =>
      '$baseUrl/winners/admin/participants/$competitionId';
  static String adminParticipantsExport(int competitionId) =>
      '$baseUrl/winners/admin/participants/$competitionId/export';

  static const String recruterStats = '$baseUrl/jobs/recruiter/stats';
  static const String registrations = '$baseUrl/registrations';
  static String getJobCandidates(String jobId) =>
      '$baseUrl/jobs/$jobId/applications';
  static String getShortlistedCandidates(String jobId) =>
      '$baseUrl/jobs/$jobId/applications?status=shortlisted';
  static String getRejectedCandidates(String jobId) =>
      '$baseUrl/jobs/$jobId/applications?status=rejected';
  static String getReservedCandidates(String jobId) =>
      '$baseUrl/jobs/$jobId/applications?status=accepted';
  static String updateCandidateStatus(String applicationId) =>
      '$baseUrl/jobs/applications/$applicationId/status';
  static String seeAllPendingCandidates =
      '$baseUrl/jobs/applications?status=pending';
  static String getUniDepartments(int programId) =>
      '$baseUrl/universities/departments/$programId';
  static String getApplicantDetails(String applicationId) =>
      '$baseUrl/jobs/applications/$applicationId';

  // Chat
  static const String chat = '$baseUrl/chat';
  static String chatById(int chatId) => '$baseUrl/chat/$chatId';
  static String chatMessages(int chatId, {int page = 1, int limit = 20}) =>
      '$baseUrl/chat/$chatId/messages?limit=$limit&page=$page';
  static const String sendChatMessage = '$baseUrl/chat/messages';
  static String readChatMessage(int messageId) =>
      '$baseUrl/chat/messages/$messageId/read';
  static String deleteChatMessage(int messageId) =>
      '$baseUrl/chat/messages/$messageId';
  static String leaveChat(int chatId) => '$baseUrl/chat/$chatId/leave';
  static String addChatMembers(int chatId) => '$baseUrl/chat/$chatId/members';
  static String removeChatMember(int chatId, int userId) =>
      '$baseUrl/chat/$chatId/members/$userId';
  // Class Schedule
  static const String classSchedule = '$baseUrl/class-schedule';
  static String classScheduleById(int id) => '$baseUrl/class-schedule/$id';

  static String getMyCVs = '$baseUrl/cv/all';
  static String downloadCV(String cvId) => '$baseUrl/cv/download/$cvId';
  static String allSubscriptions = '$baseUrl/subscriptions/packages';
  static String subscribeToPackage = '$baseUrl/subscriptions/purchase';
  static String mySubscription = '$baseUrl/subscriptions/me';
  static String claimFreeTrial = '$baseUrl/subscriptions/claim-free-trial';
  static String cancelSubscription = '$baseUrl/subscriptions/cancel-subscription';
  static String termsAndPrivacy(String type) => '$baseUrl/terms-and-privacy/type/$type';

  // Feedback Endpoints
  static const String feedbacks = '$baseUrl/feedbacks';
  static String feedbackById(int id) => '$baseUrl/feedbacks/$id';

  // Emergency Support
  static const String emergencySupport = '$baseUrl/emergency-support';

  // Referral Program
  static const String referStats = '$baseUrl/refers/userstats';
  static const String referRole = '$baseUrl/refers/get-role';
  static const String referApplyLevel = '$baseUrl/refers/level/apply';
  static const String referralPayoutRequest = '$baseUrl/refers/payout-request';
}
