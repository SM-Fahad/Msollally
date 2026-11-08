import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';

import '../../controller/gigs_controller.dart';
import 'gig_document_upload.dart';
import 'gig_dropdown.dart';
import 'gig_form_styles.dart';
import 'gig_price_row.dart';
import 'gig_submit_button.dart';
import 'gig_tag_section.dart';

class GigFormBody extends StatelessWidget {
  const GigFormBody({super.key, required this.controller});

  final GigsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gigFormSection([
          gigFieldLabel('Title *'),
          TextField(
            controller: controller.titleController,
            decoration: gigFieldDecoration('e.g. Full Stack Web Developer'),
          ),
        ]),
        gigFormSection([
          gigFieldLabel('Description *'),
          TextField(
            controller: controller.descriptionController,
            decoration: gigFieldDecoration('Describe your gig in detail...'),
            minLines: 4,
            maxLines: 6,
          ),
        ]),
        gigFormSection([
          gigFieldLabel('Price *'),
          GigPriceRow(controller: controller),
        ]),
        gigFormSection([
          gigFieldLabel('Pricing Type'),
          GigDropdown(
            items: controller.pricingTypes,
            selected: controller.selectedPricingType,
          ),
        ]),
        gigFormSection([
          gigFieldLabel('Location Type'),
          GigDropdown(
            items: controller.locationTypes,
            selected: controller.selectedLocationType,
          ),
        ]),
        gigFormSection([
          gigFieldLabel('Address'),
          TextField(
            controller: controller.addressController,
            decoration: gigFieldDecoration(
              'e.g. Dhaka, Bangladesh',
              suffix: const Icon(Icons.location_on_outlined),
            ),
          ),
        ]),
        gigFormSection([
          gigFieldLabel('Country & City'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.countryController,
                  decoration: gigFieldDecoration('Country'),
                ),
              ),
              SizedBox(width: 10.width),
              Expanded(
                child: TextField(
                  controller: controller.cityController,
                  decoration: gigFieldDecoration('City'),
                ),
              ),
            ],
          ),
        ]),
        GigTagSection(controller: controller),
        SizedBox(height: 20.height),
        GigDocumentUpload(controller: controller),
        SizedBox(height: 30.height),
        GigSubmitButton(controller: controller),
        SizedBox(height: 40.height),
      ],
    );
  }
}
