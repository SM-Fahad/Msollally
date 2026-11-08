import 'package:flutter/material.dart';

class CompetitionAppBar extends StatelessWidget {
  const CompetitionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
          const Expanded(
            child: Text(
              'CRDB Bank Student Quiz Competition',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
