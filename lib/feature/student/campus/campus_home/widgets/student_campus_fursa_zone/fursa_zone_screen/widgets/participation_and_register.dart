import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';

class ParticipationAndRegister extends StatelessWidget {
  final VoidCallback onParticipationTap;
  final VoidCallback onRegisterTap;

  const ParticipationAndRegister({
    super.key,
    required this.onParticipationTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: onParticipationTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.dodgerBlue155DFC, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 20,
                      color: AppColors.black1D1D1D,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Participation Guidance",
                      style: TextStyle(
                        color: AppColors.black1D1D1D,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
          InkWell(
            onTap: onRegisterTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 89,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.dodgerBlue155DFC,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Register",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
