import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/events/create_event/controller/create_event_controller.dart';

class AddCoHostScreen extends StatelessWidget {
  final CreateEventController controller;
  const AddCoHostScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Co-host')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: controller.onCoHostSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by user name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 12),
            Obx(() {
              if (controller.selectedCoHosts.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: controller.selectedCoHosts.map((host) {
                    final name = (host['fullName'] ?? '').toString();
                    final image = (host['image'] ?? '').toString();
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                        child: image.isEmpty ? const Icon(Icons.person, size: 14) : null,
                      ),
                      label: Text(name.isEmpty ? 'User #${host['id']}' : name),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => controller.toggleCoHost(host),
                    );
                  }).toList(),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.coHostSearchLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (controller.coHostSearchResults.isEmpty) {
                  return Center(child: Text('Type a name to search users'));
                }
                return ListView.separated(
                  itemCount: controller.coHostSearchResults.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = controller.coHostSearchResults[index];
                    final int id = user['id'] as int;
                    final name = (user['fullName'] ?? '').toString();
                    final image = (user['image'] ?? '').toString();

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        child: image.isEmpty ? Icon(Icons.person) : null,
                      ),
                      title: Text(
                        name.isEmpty ? 'Unknown user' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Obx(
                        () => Checkbox(
                          value: controller.selectedCoHostIds.contains(id),
                          onChanged: (_) => controller.toggleCoHost(user),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  EasyLoading.showSuccess(
                    '${controller.selectedCoHostIds.length} co-host selected',
                  );
                  Get.back();
                },
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
