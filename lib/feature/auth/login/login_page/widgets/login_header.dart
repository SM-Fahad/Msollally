import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36.0),
          child: Row(
            children: [
              Image.asset("assets/images/app_icon.png", height: 80, width: 80),

              Text("LinkYetu", style: getTextStyle(fontSize: 34)),
            ],
          ),
        ),
        Text(
          "Log In",
          style: getTextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
