import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import '../../controller/gigs_controller.dart';
import 'gig_form_styles.dart';

class GigPriceRow extends StatelessWidget {
  const GigPriceRow({super.key, required this.controller});

  final GigsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedCurrency.value,
              items: controller.currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: (value) => controller.selectedCurrency.value = value!,
              decoration: gigDropdownDecoration(),
              dropdownColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 10.width),
        Expanded(
          flex: 3,
          child: TextField(
            controller: controller.priceController,
            keyboardType: TextInputType.number,
            decoration: gigFieldDecoration('e.g. 500'),
          ),
        ),
      ],
    );
  }
}
