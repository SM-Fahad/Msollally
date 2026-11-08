import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/health_wellness/controller/health_wellness_controller.dart';
import 'package:msollaally/core/widgets/global_app_bar.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/feature/student/health_wellness/widgets/emergency_support_card.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class StudentWellnessScreen extends StatefulWidget {
  const StudentWellnessScreen({super.key});

  @override
  State<StudentWellnessScreen> createState() => _StudentWellnessScreenState();
}

class _StudentWellnessScreenState extends State<StudentWellnessScreen> {
  final HealthWellnessController _controller = Get.put(HealthWellnessController());

  final List<Map<String, dynamic>> typeFilters = [
    {
      'name': 'Medical',
      'value': 'medical',
      'icon': Icons.medical_services_outlined,
      'iconBg': const Color(0xFFE6F3CC), // Light green-yellow
      'iconColor': Colors.black,
    },
    {
      'name': 'Fire',
      'value': 'fire',
      'icon': Icons.local_fire_department_outlined,
      'iconBg': const Color(0xFFFFD6D6), // Light red
      'iconColor': Colors.black,
    },
    {
      'name': 'Accident',
      'value': 'accident',
      'icon': Icons.car_crash_outlined,
      'iconBg': const Color(0xFFEAE6FF), // Light purple
      'iconColor': Colors.black,
    },
    {
      'name': 'Natural disaster',
      'value': 'natural_disaster',
      'icon': Icons.business_outlined, // Fallback for building
      'iconBg': const Color(0xFFD6F5E3), // Light green
      'iconColor': Colors.black,
    },
    {
      'name': 'Rescue',
      'value': 'rescue',
      'icon': Icons.support_outlined,
      'iconBg': const Color(0xFFFFF0CC), // Light yellow
      'iconColor': Colors.black,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initForWellness();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // In screenshot, background seems mostly white
      appBar: GlobalAppBar(title: "Emergency Support"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.height),
          _buildTypeFilter(),
          SizedBox(height: 16.height),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.width),
            child: Text(
              "Emergency Contacts",
              style: appTextStyleHeading1(
                fontSize: 14.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.height),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.width),
      child: Obx(() {
        return Wrap(
          spacing: 12.width,
          runSpacing: 12.height,
          children: typeFilters.map((filter) {
            final isSelected = _controller.selectedType.value == filter['value'] || 
                (_controller.selectedType.value == 'all' && filter['value'] == 'medical'); // Fallback if 'all' is selected to make it match image where medical is blue initially maybe? Or just strict check.
            
            // Let's do a strict check, if it's 'all' we can just default to 'medical' for UI purposes or we can just let none be selected unless we override it.
            // Actually, let's just make it selected if it matches.
            final actualIsSelected = _controller.selectedType.value == filter['value'] || (_controller.selectedType.value == 'all' && filter['value'] == 'medical');

            return GestureDetector(
              onTap: () {
                _controller.selectedType.value = filter['value'] as String;
              },
              child: Container(
                padding: EdgeInsets.only(left: 4.width, right: 16.width, top: 4.height, bottom: 4.height),
                decoration: BoxDecoration(
                  color: actualIsSelected ? AppColors.primaryButtonColor : Colors.white,
                  borderRadius: BorderRadius.circular(30.radius),
                  border: Border.all(
                    color: actualIsSelected ? AppColors.primaryButtonColor : AppColors.lavenderE6EBF2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.width),
                      decoration: BoxDecoration(
                        color: filter['iconBg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        filter['icon'] as IconData,
                        size: 16.width,
                        color: filter['iconColor'] as Color,
                      ),
                    ),
                    SizedBox(width: 8.width),
                    Text(
                      filter['name'] as String,
                      style: getTextStyle(
                        color: actualIsSelected ? Colors.white : Colors.black87,
                        fontSize: 13.fontSize,
                        fontWeight: actualIsSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.emergencySupportList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_controller.emergencySupportList.isEmpty) {
        return RefreshIndicator(
          onRefresh: _controller.refreshData,
          child: ListView(
            children: [
              SizedBox(height: 100.height),
              Center(child: Text("No records found.", style: getTextStyle(color: Colors.grey))),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _controller.refreshData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller.scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.width),
          itemCount: _controller.emergencySupportList.length + 1,
          itemBuilder: (context, index) {
            if (index == _controller.emergencySupportList.length) {
              return _controller.isLoadingMore.value
                  ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                  : const SizedBox.shrink();
            }
            final item = _controller.emergencySupportList[index];
            return EmergencySupportCard(item: item);
          },
        ),
      );
    });
  }
}
