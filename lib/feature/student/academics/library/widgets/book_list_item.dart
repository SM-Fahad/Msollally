import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/library/model/library_model.dart';
import 'package:msollaally/feature/student/academics/library/screen/pdf_viewer.dart';
import '../controller/library_controller.dart';

class BookListItem extends StatelessWidget {
  final BookModel book;
  final LibraryController controller;

  const BookListItem({super.key, required this.book, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PdfViewerPage(book: book));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: book.coverImage != null && book.coverImage!.url.isNotEmpty
                  ? Image.network(
                      book.coverImage!.url,
                      height: 80,
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80,
                        width: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 80,
                      width: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),

            /// Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Author: ${book.author}",
                    style: getTextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),

                  /// Actions (Wishlist, Plan, Read)
                  Row(
                    children: [
                      Obx(
                        () => IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            book.isWishlisted.value
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.toggleWishlist(book);
                          },
                        ),
                      ),
                      Text("Wishlist", style: getTextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => controller.addToPlan(book),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.event_note,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text("Plan", style: getTextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            book.isRead.value
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: Colors.lightBlueAccent,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.toggleRead(book);
                          },
                        ),
                      ),
                      Text("Read", style: getTextStyle(fontSize: 12)),
                    ],
                  ),

                  /// Helpful Count and Reads Count
                  Obx(
                    () => Row(
                      children: [
                        InkWell(
                          onTap: () => controller.toggleHelpful(book),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                            child: Row(
                              children: [
                                Icon(
                                  book.isLiked.value
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: book.isLiked.value
                                      ? Colors.blue
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${book.totalLikes.value} Helpful",
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: book.isLiked.value
                                        ? Colors.blue
                                        : Colors.grey,
                                    fontWeight: book.isLiked.value
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        InkWell(
                          onTap: () => controller.toggleRead(book),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  color: book.isRead.value
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${book.totalReads.value} Reads",
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: book.isRead.value
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: book.isRead.value
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
