import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/gigs_controller.dart';
import '../../screen/create_gig_screen.dart';
import '../../model/gigs_model.dart';

class GigDetailActionMenu extends StatelessWidget {
  const GigDetailActionMenu({
    super.key,
    required this.controller,
    required this.gig,
  });

  final GigsController controller;
  final GigsModel gig;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: controller.getCurrentUserId(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data ?? -1;
        final isOwner =
            currentUserId != -1 &&
            gig.author != null &&
            gig.author!.id == currentUserId;

        if (!isOwner) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete' && gig.gigId != null) {
              _showDeleteDialog(context);
              return;
            }

            if (value == 'edit') {
              controller.populateFormForEdit(gig);
              Get.to(() => const CreateGigScreen());
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Gig', style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete Gig', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Gig'),
        content: const Text(
          'Are you sure you want to delete this gig? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              controller.deleteGig(gig.gigId!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
