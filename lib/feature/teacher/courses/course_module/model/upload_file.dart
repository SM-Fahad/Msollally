import 'package:get/get.dart';

class UploadFile {
  final String name;
  final double size;
  final String path;
  final String? extension;

  final RxDouble progress;
  RxBool isUploading;
  RxBool isCompleted;

  UploadFile({
    required this.name,
    required this.size,
    required this.path,
    this.extension,
    double progress = 0.0,
  }) : progress = progress.obs,
       isUploading = true.obs,
       isCompleted = false.obs;
}
