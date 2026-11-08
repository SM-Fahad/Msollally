import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../model/gigs_model.dart';

class GigDetailMetaSections extends StatelessWidget {
  const GigDetailMetaSections({super.key, required this.gig});

  final GigsModel gig;

  @override
  Widget build(BuildContext context) {
    final status = gig.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10.width,
          runSpacing: 8.height,
          children: [
            _GigBadge(
              text: '${gig.currency} ${gig.price} / ${gig.pricingType}',
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade700,
              icon: Icons.attach_money,
            ),
            _GigBadge(
              text:
                  gig.locationType[0].toUpperCase() +
                  gig.locationType.substring(1),
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
              icon: Icons.work_outline,
            ),
            if (status != null && status.isNotEmpty)
              _GigBadge(
                text: status[0].toUpperCase() + status.substring(1),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                icon: Icons.check_circle_outline,
              ),
          ],
        ),
        if (gig.address.isNotEmpty ||
            gig.city.isNotEmpty ||
            gig.country.isNotEmpty) ...[
          SizedBox(height: 18.height),
          if (gig.address.isNotEmpty)
            _GigInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: gig.address,
            ),
          if (gig.city.isNotEmpty || gig.country.isNotEmpty) ...[
            if (gig.address.isNotEmpty) SizedBox(height: 8.height),
            _GigInfoRow(
              icon: Icons.map_outlined,
              label: 'City / Country',
              value: [
                gig.city,
                gig.country,
              ].where((value) => value.isNotEmpty).join(', '),
            ),
          ],
        ],
      ],
    );
  }
}

class _GigBadge extends StatelessWidget {
  const _GigBadge({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 7.height),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.fontSize, color: foregroundColor),
          SizedBox(width: 5.width),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.fontSize,
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GigInfoRow extends StatelessWidget {
  const _GigInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.fontSize, color: Colors.grey.shade500),
        SizedBox(width: 8.width),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11.fontSize, color: Colors.grey.shade500),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14.fontSize, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
