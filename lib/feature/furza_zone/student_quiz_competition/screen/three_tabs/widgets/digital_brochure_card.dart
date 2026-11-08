import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class DigitalBrochureCard extends StatelessWidget {
  const DigitalBrochureCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('📄 What is a Personal Loan?'),
            _BodyText(
              'A personal loan is an unsecured loan offered by CRDB Bank to help you meet your financial needs. Whether it\'s for education, medical expenses, home improvements, or consolidating debt, our personal loans provide flexible solutions tailored to your needs.',
            ),

            _SectionTitle('💰 Key Features'),
            _Bullet('Loan Amount: Up to TZS 50,000,000'),
            _Bullet(
              'Interest Rate: Competitive rates starting from 18% per annum',
            ),
            _Bullet('Repayment Period: Flexible terms from 6 to 60 months'),
            _Bullet('Processing Time: Quick approval within 48 hours'),
            _Bullet('No Collateral: Unsecured loan for salaried customers'),

            _SectionTitle('✅ Eligibility Criteria'),
            _Bullet('Minimum age: 21 years'),
            _Bullet('Maximum age: 60 years at loan maturity'),
            _Bullet('Must be a salaried employee'),
            _Bullet('Minimum monthly income: TZS 400,000'),
            _Bullet('Clean credit history'),
            _Bullet('CRDB account holder (current or savings account)'),

            _SectionTitle('📑 Required Documents'),
            _Bullet('Valid National ID or Passport'),
            _Bullet('Recent passport-size photograph'),
            _Bullet('Last 3 months\' salary slips'),
            _Bullet('Employment confirmation letter'),
            _Bullet('Last 6 months\' bank statements'),
            _Bullet('Proof of residence (utility bill)'),

            _SectionTitle('📊 Loan Calculation Example'),
            _BodyText('Loan Amount: TZS 10,000,000'),
            _BodyText('Interest Rate: 20% per annum'),
            _BodyText('Loan Period: 24 months'),
            _BodyText('Monthly Payment: TZS 509,000'),

            _SectionTitle('🎯 Benefits'),
            _Bullet('Flexible Repayment: Choose terms that suit your budget'),
            _Bullet('Quick Processing: Fast approval and disbursement'),
            _Bullet('No Hidden Charges: Transparent fee structure'),
            _Bullet('Top-up Facility: Increase your loan after 6 months'),
            _Bullet('Insurance Cover: Optional credit life insurance'),

            _SectionTitle('📞 How to Apply'),
            _Numbered('Visit your nearest CRDB branch'),
            _Numbered('Submit completed application form with documents'),
            _Numbered('Wait for credit assessment (24–48 hours)'),
            _Numbered('Sign loan agreement upon approval'),
            _Numbered('Receive funds in your account'),

            _SectionTitle('⚠️ Important Notes'),
            _Bullet(
              'Interest rates are subject to change based on market conditions',
            ),
            _Bullet('Processing fees apply (1% of loan amount)'),
            _Bullet('Early repayment allowed without penalties'),
            _Bullet('Late payment fees may apply'),
            _Bullet('Terms and conditions apply'),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '• $text',
        style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor),
      ),
    );
  }
}

class _Numbered extends StatelessWidget {
  final String text;
  const _Numbered(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: getTextStyle(fontSize: 13, color: AppColors.secondaryTextColor),
      ),
    );
  }
}
