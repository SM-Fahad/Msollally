import '../../../core/const/icons_path.dart';

class NavbarItem {
  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final bool hasNotification;
  final String? notificationCount;
  final String? route;

  NavbarItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    this.hasNotification = false,
    this.notificationCount,
    this.route,
  });
}

enum UserProfile { student, teacher, recruiter, proPartners }

class NavbarConfig {
  static List<NavbarItem> getNavbarItems(UserProfile profile) {
    switch (profile) {
      case UserProfile.student:
        return [
          NavbarItem(
            label: 'Home',
            activeIcon: IconsPath.studentHome,
            inactiveIcon: IconsPath.studentHomeInactive,
          ),
          NavbarItem(
            label: 'Academics',
            activeIcon: IconsPath.studentAcademics,
            inactiveIcon: IconsPath.studentAcademicsInactive,
          ),
          NavbarItem(
            label: 'Campus',
            activeIcon: IconsPath.studentCampus,
            inactiveIcon: IconsPath.studentCampusInactive,
            hasNotification: true,
            notificationCount: '99+',
          ),
          NavbarItem(
            label: 'Career',
            activeIcon: IconsPath.studentCareer,
            inactiveIcon: IconsPath.studentCareerInactive,
          ),
          NavbarItem(
            label: 'More',
            activeIcon: IconsPath.studentMore,
            inactiveIcon: IconsPath.studentMoreInactive,
          ),
        ];
      case UserProfile.teacher:
        return [
          NavbarItem(
            label: 'Home',
            activeIcon: IconsPath.teacherHome,
            inactiveIcon: IconsPath.teacherHomeInactive,
          ),
          NavbarItem(
            label: 'Courses',
            activeIcon: IconsPath.teacherCourses,
            inactiveIcon: IconsPath.teacherCoursesInactive,
          ),
          NavbarItem(
            label: 'Students',
            activeIcon: IconsPath.teacherStudents,
            inactiveIcon: IconsPath.teacherStudentsInactive,
            hasNotification: true,
            notificationCount: '5',
          ),
          NavbarItem(
            label: 'More',
            activeIcon: IconsPath.teacherMore,
            inactiveIcon: IconsPath.teacherMoreInactive,
          ),
        ];
      case UserProfile.recruiter:
        return [
          NavbarItem(
            label: 'Home',
            activeIcon: IconsPath.recruiterHome,
            inactiveIcon: IconsPath.recruiterHomeInactive,
          ),
          NavbarItem(
            label: 'Jobs',
            activeIcon: IconsPath.recruiterJobs,
            inactiveIcon: IconsPath.recruiterJobsInactive,
            hasNotification: true,
            notificationCount: '12',
          ),
          NavbarItem(
            label: 'Candidates',
            activeIcon: IconsPath.recruiterCandidates,
            inactiveIcon: IconsPath.recruiterCandidatesInactive,
          ),
          NavbarItem(
            label: 'More',
            activeIcon: IconsPath.recruiterMore,
            inactiveIcon: IconsPath.recruiterMoreInactive,
          ),
        ];
      case UserProfile.proPartners:
        return [
          NavbarItem(
            label: 'Dashboard',
            activeIcon: IconsPath.proPartnersDashboard,
            inactiveIcon: IconsPath.proPartnersDashboardInactive,
          ),
          NavbarItem(
            label: 'Campaign',
            activeIcon: IconsPath.proPartnersCampaign,
            inactiveIcon: IconsPath.proPartnersCampaignInactive,
          ),
          NavbarItem(
            label: 'Events',
            activeIcon: IconsPath.proPartnersEvents,
            inactiveIcon: IconsPath.proPartnersEventsInactive,
            hasNotification: true,
            notificationCount: '8',
          ),
          NavbarItem(
            label: 'Jobs',
            activeIcon: IconsPath.proPartnersJobs,
            inactiveIcon: IconsPath.proPartnersJobsInactive,
          ),
          NavbarItem(
            label: 'More',
            activeIcon: IconsPath.proPartnersMore,
            inactiveIcon: IconsPath.proPartnersMoreInactive,
          ),
        ];
    }
  }
}
