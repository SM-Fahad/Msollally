import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../screen/qbank_pdf_viewer.dart';

class QbankDocumentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String url;
  final String title;

  const QbankDocumentButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: getTextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          if (url.isEmpty) {
            EasyLoading.showInfo("Document URL is not available.");
            return;
          }
          Get.to(() => QbankPdfViewer(url: url, title: title));
        },
      ),
    );
  }
}
