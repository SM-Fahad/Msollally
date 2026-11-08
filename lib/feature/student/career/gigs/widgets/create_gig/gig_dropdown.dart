import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'gig_form_styles.dart';

class GigDropdown extends StatelessWidget {
  const GigDropdown({super.key, required this.items, required this.selected});

  final List<String> items;
  final RxString selected;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DropdownButtonFormField<String>(
        initialValue: selected.value,
        items: items
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(
                  value.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => selected.value = value!,
        decoration: gigDropdownDecoration(),
        dropdownColor: Colors.white,
      ),
    );
  }
}
