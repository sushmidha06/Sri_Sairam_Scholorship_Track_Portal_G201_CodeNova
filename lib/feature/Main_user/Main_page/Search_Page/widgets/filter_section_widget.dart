

// ==================== widgets/filter_section_widget.dart ====================
import 'package:flutter/material.dart';

class FilterSectionWidget extends StatelessWidget {
  final String selectedCategory;
  final String minAmount;
  final List<String> categories;
  final Function(String?) onCategoryChanged;
  final Function(String) onAmountChanged;
  final Color themeColor;

  const FilterSectionWidget({
    Key? key,
    required this.selectedCategory,
    required this.minAmount,
    required this.categories,
    required this.onCategoryChanged,
    required this.onAmountChanged,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: themeColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Minimum Amount (\$)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeColor,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 3000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
            ),
            onChanged: onAmountChanged,
          ),
        ],
      ),
    );
  }
}