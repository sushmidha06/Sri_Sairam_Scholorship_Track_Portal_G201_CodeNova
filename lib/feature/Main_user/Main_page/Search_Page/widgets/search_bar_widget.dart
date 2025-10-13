

// ==================== widgets/search_bar_widget.dart ====================
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Color themeColor;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 2),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search scholarships by name, category, or eligibility...',
          prefixIcon: Icon(Icons.search, color: themeColor, size: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}