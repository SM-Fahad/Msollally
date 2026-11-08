import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../model/library_model.dart';
import '../service/library_service.dart';

class LibraryController extends GetxController {
  var books = <BookModel>[].obs;
  var filteredBooks = <BookModel>[].obs;

  var selectedTab = 0.obs;
  var isLoading = false.obs;
  var isDetailsLoading = false.obs;
  var errorMessage = ''.obs;
  var bookDetails = Rxn<BookModel>();

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBookDetails(String id) async {
    try {
      EasyLoading.show(status: 'Please wait while loading');
      isDetailsLoading.value = true;
      bookDetails.value = null;
      final details = await LibraryService.getBookById(id);
      bookDetails.value = details;
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      debugPrint('Error fetching book details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> fetchBooks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      EasyLoading.show(status: 'Please wait while loading');

      final fetchedBooks = await LibraryService.getBooks();
      books.assignAll(fetchedBooks);

      changeTab(selectedTab.value);
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      errorMessage.value = e.toString();
      debugPrint('Error fetching books: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 0) {
      filteredBooks.assignAll(books);
    } else if (index == 1) {
      filteredBooks.assignAll(
        books.where((b) => b.isWishlisted.value).toList(),
      );
    } else if (index == 2) {
      filteredBooks.assignAll(books.where((b) => b.isRead.value).toList());
    }
  }

  void toggleWishlist(BookModel book) {
    book.isWishlisted.value = !book.isWishlisted.value;
    changeTab(selectedTab.value);
  }

  void toggleRead(BookModel book) {
    book.isRead.value = !book.isRead.value;
    if (book.isRead.value) {
      book.totalReads.value += 1;
      EasyLoading.showToast('Marked as read');
    }
    changeTab(selectedTab.value);
  }

  void toggleHelpful(BookModel book) {
    if (book.isLiked.value) {
      book.isLiked.value = false;
      if (book.totalLikes.value > 0) book.totalLikes.value -= 1;
      EasyLoading.showToast('Removed helpful mark');
    } else {
      book.isLiked.value = true;
      book.totalLikes.value += 1;
      EasyLoading.showToast('Marked as helpful');
    }
  }

  void addToPlan(BookModel book) {
    Get.snackbar(
      'Study Plan',
      'Added "${book.title}" to your study goals.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void searchBooks(String query) {
    if (query.isEmpty) {
      changeTab(selectedTab.value);
    } else {
      var sourceList = <BookModel>[];
      if (selectedTab.value == 0) {
        sourceList = books;
      } else if (selectedTab.value == 1) {
        sourceList = books.where((b) => b.isWishlisted.value).toList();
      } else if (selectedTab.value == 2) {
        sourceList = books.where((b) => b.isRead.value).toList();
      }

      filteredBooks.assignAll(
        sourceList.where(
          (b) =>
              b.title.toLowerCase().contains(query.toLowerCase()) ||
              b.author.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }
}
