import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

import '../../model/gigs_model.dart';

class GigDetailHeader extends StatelessWidget {
  const GigDetailHeader({super.key, required this.gig});

  final GigsModel gig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                gig.title,
                style: getTextStyle(
                  fontSize: 20.fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 12.width),
          ],
        ),
        if (gig.author?.username != null) ...[
          SizedBox(height: 6.height),
          Row(
            children: [
              CircleAvatar(
                radius: 10.radius,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  gig.author!.username![0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.fontSize,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              SizedBox(width: 6.width),
              Text(
                gig.author!.username!,
                style: TextStyle(fontSize: 13.fontSize, color: Colors.grey.shade600),
              ),
              if (gig.author?.role != null) ...[
                SizedBox(width: 6.width),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 2.height),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.radius),
                  ),
                  child: Text(
                    gig.author!.role!,
                    style: TextStyle(
                      fontSize: 11.fontSize,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
