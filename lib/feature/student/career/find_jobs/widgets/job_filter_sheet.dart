import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/jobs.controller.dart';

class JobFilterSheet extends StatelessWidget {
  final JobController controller;

  const JobFilterSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          // Filter options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Type
                  const Text(
                    'Job Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: controller.availableJobTypes.map((type) {
                        final isSelected = controller.selectedFilters.contains(
                          type,
                        );
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (_) => controller.toggleFilter(type),
                          selectedColor: Colors.blue.shade100,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: controller.availableLocations.map((location) {
                        final isSelected = controller.selectedFilters.contains(
                          location,
                        );
                        return FilterChip(
                          label: Text(location),
                          selected: isSelected,
                          onSelected: (_) => controller.toggleFilter(location),
                          selectedColor: Colors.blue.shade100,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
