import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class EventHeaderCard extends StatelessWidget {
  final Map<String, dynamic> card;
  const EventHeaderCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.whiteSmokeECECEC),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.whiteSmokeF2F2F4,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.event_outlined,
                    size: 28,
                    color: AppColors.darkSlateGray4A4A4A,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.darkGray9A9A9A,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: Text(
                              card['date'] ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.darkGray9A9A9A,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: Text(
                              card['location'] ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if ((card['description'] ?? '').isNotEmpty)
                      Text(card['description'], style: TextStyle(fontSize: 14)),
                    SizedBox(height: 8),
                    if ((card['cohosts'] ?? '').isNotEmpty)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Co-hosts:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            card['cohosts'],
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.gray7A7A7A,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteSmokeF2F6F9,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Guest Message Group Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkSlateGray4A4A4A,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    (card['rsvps'] ?? 0).toString(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Opacity(opacity: 0.7, child: Text('RSVPs')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
