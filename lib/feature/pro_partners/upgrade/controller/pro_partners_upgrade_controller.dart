import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/upgrade/model/pro_partners_upgrade_model.dart';
import 'package:msollaally/feature/pro_partners/upgrade/widgets/payment_completed_dialog.dart';

class ProPartnersUpgradeController extends GetxController {
  final RxList<ProPartnersUpgradeModel> upgradeListItems =
      <ProPartnersUpgradeModel>[].obs;

  final TextEditingController referralCodeController = TextEditingController();

  final isDiscountApplied = false.obs;
  final originalAmount = 0.0.obs;
  final discountedAmount = 0.0.obs;
  final selectedPaymentMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();

    upgradeListItems.addAll([
      ProPartnersUpgradeModel(
        title: 'Yearly',
        subTitle: 'Includes all premium features',
        charge: 'TZS 10,000 year',
        initializedChecked: true,
      ),
      ProPartnersUpgradeModel(
        title: 'Monthly',
        subTitle: 'Includes all premium features',
        charge: 'TZS 1,500/month',
        initializedChecked: false,
      ),
      ProPartnersUpgradeModel(
        title: 'Quarterly',
        subTitle: 'Includes all premium features',
        charge: 'TZS 3,000/month',
        initializedChecked: false,
      ),
    ]);
  }

  void selectUpgradeItem(int index) {
    for (var i = 0; i < upgradeListItems.length; i++) {
      upgradeListItems[i].isChecked.value = i == index;
    }
  }

  ProPartnersUpgradeModel? getSelectedPlan() {
    try {
      return upgradeListItems.firstWhere((item) => item.isChecked.value);
    } catch (_) {
      return null;
    }
  }

  void applyReferralCode(String code) {
    // Keeping the same behavior as the student reference implementation.
    if (code == '') {
      isDiscountApplied.value = true;

      final selectedPlan = getSelectedPlan();
      if (selectedPlan != null) {
        final amount = extractAmount(selectedPlan.charge);
        originalAmount.value = amount;
        discountedAmount.value = amount * 0.5;
      }

      EasyLoading.showSuccess('50% Discount Applied ✅');
    } else {
      EasyLoading.showError('The referral code is invalid');
    }
  }

  double extractAmount(String charge) {
    final value = charge.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(value) ?? 0;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void processPayment() {
    if (selectedPaymentMethod.value.isEmpty) {
      EasyLoading.showError('Please select a payment method');
      return;
    }

    Get.back();
    Future.delayed(
      const Duration(milliseconds: 500),
      showPaymentCompletedDialog,
    );
  }
}
