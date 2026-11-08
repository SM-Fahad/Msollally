class PlanModel {
  final String date; // e.g. "14 Aug, 2025"
  final String time; // e.g. "17:00 - 18:00"
  final String task; // e.g. "Review Chapter 1: Kinematics"

  PlanModel({required this.date, required this.time, required this.task});
}

class PlanSession {
  final String date; // e.g. "Mon, July 21, 2025"
  final String time; // e.g. "16:00 - 17:00"
  final String title; // e.g. "Understanding Thermodynamics"
  final String task; // e.g. "Review Chapter 1: Kinematics"
  final String status; // "ongoing", "upcoming", "completed"
  final int progress; // % completed
  final String timer; // e.g. "37:23"

  PlanSession({
    required this.date,
    required this.time,
    required this.title,
    required this.task,
    required this.status,
    this.progress = 0,
    this.timer = "00:00",
  });
}
