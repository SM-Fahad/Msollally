import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/gigs_model.dart';

class GigDetailContentSections extends StatelessWidget {
  const GigDetailContentSections({super.key, required this.gig});

  final GigsModel gig;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.height),
        Text(
          'Description',
          style: TextStyle(fontSize: 15.fontSize, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.height),
        Text(
          gig.description,
          style: TextStyle(fontSize: 14.fontSize, color: Colors.black87, height: 1.5),
        ),
        if (gig.tags.isNotEmpty) ...[
          SizedBox(height: 20.height),
          Text(
            'Skills / Tags',
            style: TextStyle(fontSize: 15.fontSize, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.height),
          Wrap(
            spacing: 8.width,
            runSpacing: 6.height,
            children: gig.tags
                .map(
                  (tag) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.width,
                      vertical: 6.height,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20.radius),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12.fontSize,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (gig.documents.isNotEmpty) ...[
          SizedBox(height: 20.height),
          Text(
            'Attached Media / Documents',
            style: TextStyle(fontSize: 15.fontSize, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.height),
          ...gig.documents.asMap().entries.map((entry) {
            final docUrl = entry.value;
            final isPdfOrDoc =
                docUrl.toLowerCase().endsWith('.pdf') ||
                docUrl.toLowerCase().endsWith('.doc') ||
                docUrl.toLowerCase().endsWith('.docx');

            Widget documentTile() {
              return Container(
                margin: EdgeInsets.only(bottom: 8.height),
                padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.radius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_outlined,
                      size: 18.fontSize,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 10.width),
                    Expanded(
                      child: Text(
                        'Document ${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 13.fontSize,
                          color: Colors.blue.shade700,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isPdfOrDoc) {
              return documentTile();
            }

            return Container(
              margin: EdgeInsets.only(bottom: 12.height),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.radius),
                child: Image.network(
                  docUrl,
                  height: 235.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 235.height,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => documentTile(),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
