import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/terms_and_privacy/controller/terms_and_privacy_controller.dart';
import 'package:msollaally/core/utils/responsive.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String type = args['type'] ?? 'terms';
    final String title = args['title'] ?? 'Terms & Conditions';

    final controller = Get.put(
      TermsAndPrivacyController(type: type),
      tag: type,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.appBarTitleColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: appTextStyleHeading2().copyWith(
            color: AppColors.appBarTitleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.appBarBottomColor,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = controller.termsData.value;
                if (data == null || data.content == null) {
                  return Center(
                    child: Text(
                      "Data not available",
                      style: appTextStyleHeading2(),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.width,
                    vertical: 16.height,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Html(
                        data: data.content ?? '',
                        extensions: const [
                          TableHtmlExtension(),
                          IframeHtmlExtension(),
                        ],
                        style: {
                          "body": Style(
                            fontSize: FontSize(14.0),
                            color: AppColors.appBarTitleColor,
                            fontFamily: 'Inter',
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 10.0),
                            lineHeight: const LineHeight(1.5),
                          ),
                          "h1": Style(
                            fontSize: FontSize(22.0),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 20.0, bottom: 10.0),
                          ),
                          "h2": Style(
                            fontSize: FontSize(18.0),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(top: 15.0, bottom: 8.0),
                          ),
                          "table": Style(
                            border: Border.all(color: Colors.grey.shade300),
                            margin: Margins.only(bottom: 20.0),
                            width: Width(constraints.maxWidth - 2), // Exact pixel width!
                          ),
                      "td": Style(
                        padding: HtmlPaddings.all(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      "th": Style(
                        padding: HtmlPaddings.all(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    },
                  );
                },
              ),
            );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
