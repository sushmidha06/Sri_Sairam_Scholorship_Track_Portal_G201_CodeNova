import 'package:flutter/material.dart';
import 'package:scholarship/theme/app_colors.dart';
import 'package:scholarship/models/scholarship_model.dart';

class HomeContent extends StatelessWidget {
  final List<Scholarship> recommendedScholarships;
  final List<Scholarship> allScholarships;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final ScrollController scrollController;
  final Map<GlobalKey, String> filterKeys;

  const HomeContent({
    Key? key,
    required this.recommendedScholarships,
    required this.allScholarships,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.scrollController,
    required this.filterKeys,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Scholarship Portal'),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.darkTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 48, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Find the perfect scholarship\nfor your education journey',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FilterHeaderDelegate(
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
            filterKeys: filterKeys,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (selectedFilter == 'Recommended' || selectedFilter == 'All')
                _buildScholarshipSection(
                  context,
                  title: 'Recommended for You',
                  scholarships: recommendedScholarships,
                  key: filterKeys.entries
                      .firstWhere((e) => e.value == 'Recommended')
                      .key,
                ),
              if (selectedFilter == 'Based on Profile' || selectedFilter == 'All')
                _buildScholarshipSection(
                  context,
                  title: 'Based on Your Profile',
                  scholarships: allScholarships
                      .where((s) => s.tag == 'Popular')
                      .toList(),
                  key: filterKeys.entries
                      .firstWhere((e) => e.value == 'Based on Profile')
                      .key,
                ),
              if (selectedFilter == 'Previously Viewed' || selectedFilter == 'All')
                _buildScholarshipSection(
                  context,
                  title: 'Previously Viewed',
                  scholarships: allScholarships
                      .where((s) => s.tag == 'Closing Soon')
                      .toList(),
                  key: filterKeys.entries
                      .firstWhere((e) => e.value == 'Previously Viewed')
                      .key,
                ),
              if (selectedFilter == 'Top Rated' || selectedFilter == 'All')
                _buildScholarshipSection(
                  context,
                  title: 'Top Rated Scholarships',
                  scholarships: allScholarships
                      .where((s) => s.tag == 'New')
                      .toList(),
                  key: filterKeys.entries
                      .firstWhere((e) => e.value == 'Top Rated')
                      .key,
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildScholarshipSection(
    BuildContext context, {
    required String title,
    required List<Scholarship> scholarships,
    required GlobalKey key,
  }) {
    if (scholarships.isEmpty) return const SizedBox.shrink();

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...scholarships.map((scholarship) => _buildScholarshipCard(context, scholarship)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScholarshipCard(BuildContext context, Scholarship scholarship) {
    final daysLeft = scholarship.deadline.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Handle scholarship tap
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      scholarship.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (scholarship.tag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getTagColor(scholarship.tag).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        scholarship.tag,
                        style: TextStyle(
                          color: _getTagColor(scholarship.tag),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    scholarship.eligibility,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Closes in $daysLeft days',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Handle apply now
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(color: AppColors.primaryTeal),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'New':
        return Colors.green;
      case 'Closing Soon':
        return Colors.orange;
      case 'Popular':
        return Colors.purple;
      default:
        return AppColors.primaryTeal;
    }
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Map<GlobalKey, String> filterKeys;

  _FilterHeaderDelegate({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterKeys,
  });

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, 'All'),
            const SizedBox(width: 8.0),
            _buildFilterChip(context, 'Recommended'),
            const SizedBox(width: 8.0),
            _buildFilterChip(context, 'Based on Profile'),
            const SizedBox(width: 8.0),
            _buildFilterChip(context, 'Previously Viewed'),
            const SizedBox(width: 8.0),
            _buildFilterChip(context, 'Top Rated'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String filter) {
    final isSelected = selectedFilter == filter;
    final key = filterKeys.entries.firstWhere(
      (e) => e.value == filter,
      orElse: () => MapEntry(GlobalKey(), ''),
    );

    return FilterChip(
      key: key.key,
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        onFilterChanged(filter);
        // Scroll to section
        if (selected && key.key.currentContext != null) {
          Scrollable.ensureVisible(
            key.key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primaryTeal.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryTeal : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryTeal : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return oldDelegate.selectedFilter != selectedFilter;
  }
}
