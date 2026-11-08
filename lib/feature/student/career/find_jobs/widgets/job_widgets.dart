import 'package:flutter/material.dart';

Color getJobTypeColor(String jobType) {
  switch (jobType.toLowerCase()) {
    case 'full-time':
      return Colors.blue;
    case 'part-time':
      return Colors.orange;
    case 'internship':
      return Colors.purple;
    case 'contract':
      return Colors.green;
    default:
      return Colors.grey;
  }
}
