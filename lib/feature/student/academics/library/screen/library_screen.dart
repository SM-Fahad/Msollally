import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../controller/library_controller.dart';
import '../widgets/library_header.dart';
import '../widgets/library_search_bar.dart';
import '../widgets/library_tab_bar.dart';
import '../widgets/book_list_item.dart';

class StudentLibraryScreen extends StatelessWidget {
  const StudentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryController = Get.put(LibraryController());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LibraryHeader(),
          const SizedBox(height: 16),
          LibrarySearchBar(controller: libraryController),
          const SizedBox(height: 16),
          LibraryTabBar(controller: libraryController),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (libraryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (libraryController.filteredBooks.isEmpty) {
                return Center(
                  child: Text(
                    "No books found",
                    style: getTextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                itemCount: libraryController.filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = libraryController.filteredBooks[index];
                  return BookListItem(
                    book: book,
                    controller: libraryController,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
