import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class PremiumPaymentWebviewScreen extends StatefulWidget {
  const PremiumPaymentWebviewScreen({super.key});

  @override
  State<PremiumPaymentWebviewScreen> createState() =>
      _PremiumPaymentWebviewScreenState();
}

class _PremiumPaymentWebviewScreenState extends State<PremiumPaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final paymentUrl = Get.arguments as String?;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle success or cancellation callbacks if they redirect
            // e.g., if (request.url.contains('payment-success')) ...
            return NavigationDecision.navigate;
          },
        ),
      );

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      _controller.loadRequest(Uri.parse(paymentUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.black18181B, size: 24.radius),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Complete Payment",
          style: appTextStyleHeading1(
            color: AppColors.black18181B,
            fontSize: 18.fontSize,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.height),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.height,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.mediumSeaGreen57C773,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
