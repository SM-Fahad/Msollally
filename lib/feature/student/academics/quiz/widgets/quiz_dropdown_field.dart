import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';

class QuizDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const QuizDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getTextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              dropdownColor: Colors.white,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        style: getTextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              selectedItemBuilder: (context) {
                return items
                    .map(
                      (item) => Text(
                        itemLabel(item),
                        style: getTextStyle(color: Colors.black),
                      ),
                    )
                    .toList();
              },
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
