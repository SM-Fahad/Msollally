import 'package:flutter/material.dart';
import 'package:msollaally/core/const/icons_path.dart';
import '../controller/library_controller.dart';

class LibrarySearchBar extends StatelessWidget {
  final LibraryController controller;

  const LibrarySearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => controller.searchBooks(value),
      decoration: InputDecoration(
        hintText: "Search",
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            IconsPath.searchIcon,
            width: 20,
            height: 20,
            color: Colors.grey,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
