

// ==================== widgets/suggestion_list_widget.dart ====================
import 'package:flutter/material.dart';
import 'package:scholarship/pages/Search_Page/models/scholarship.dart';

class SuggestionListWidget extends StatelessWidget {
  final List<Scholarship> suggestions;
  final Function(Scholarship) onSuggestionTap;
  final Color themeColor;

  const SuggestionListWidget({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.themeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final scholarship = suggestions[index];
          return InkWell(
            onTap: () => onSuggestionTap(scholarship),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scholarship.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${scholarship.category} • \$${scholarship.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}