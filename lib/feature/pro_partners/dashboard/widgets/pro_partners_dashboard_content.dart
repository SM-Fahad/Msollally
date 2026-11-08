import 'package:flutter/material.dart';

class ProPartnersDashboardContent extends StatelessWidget {
  const ProPartnersDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center_outlined, size: 80, color: Colors.purple),
          SizedBox(height: 20),
          Text(
            'Welcome to Pro Partners Portal',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Use the navigation bar below to explore',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
