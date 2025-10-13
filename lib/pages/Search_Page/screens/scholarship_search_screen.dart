// ==================== screens/scholarship_search_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:scholarship/pages/Search_Page/data/scholarship_data.dart';
import 'package:scholarship/pages/Search_Page/models/scholarship.dart';
import 'package:scholarship/pages/Search_Page/utils/trie.dart';
import 'package:scholarship/pages/Search_Page/widgets/filter_section_widget.dart';
import 'package:scholarship/pages/Search_Page/widgets/scholarship_card_widget.dart';
import 'package:scholarship/pages/Search_Page/widgets/search_bar_widget.dart';
import 'package:scholarship/pages/Search_Page/widgets/suggestion_list_widget.dart';
import 'package:scholarship/theme/app_colors.dart';


class ScholarshipSearchScreen extends StatefulWidget {
  const ScholarshipSearchScreen({Key? key}) : super(key: key);

  @override
  State<ScholarshipSearchScreen> createState() => _ScholarshipSearchScreenState();
}

class _ScholarshipSearchScreenState extends State<ScholarshipSearchScreen> {
  final Color themeColor = Color.fromARGB(255, 0, 150, 136);
  final TextEditingController _searchController = TextEditingController();
  
  late Trie _trie;
  List<Scholarship> _allScholarships = [];
  List<Scholarship> _filteredScholarships = [];
  List<Scholarship> _suggestions = [];
  
  String _selectedCategory = 'All';
  String _minAmount = '';
  bool _showFilters = false;
  
  final List<String> _categories = [
    'All',
    'Merit-based',
    'STEM',
    'Service',
    'Arts',
    'Need-based'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _allScholarships = ScholarshipData.getScholarships();
    _filteredScholarships = _allScholarships;
    
    // Initialize Trie
    _trie = Trie();
    for (var scholarship in _allScholarships) {
      _trie.insert(scholarship.name, scholarship);
      _trie.insert(scholarship.category, scholarship);
      
      // Insert eligibility keywords
      scholarship.eligibility.split(' ').forEach((word) {
        if (word.length > 2) {
          _trie.insert(word, scholarship);
        }
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        var results = _trie.search(value);
        // Remove duplicates
        var seen = <int>{};
        _suggestions = results.where((s) => seen.add(s.id)).take(5).toList();
      } else {
        _suggestions = [];
      }
      _filterScholarships();
    });
  }

  void _filterScholarships() {
    setState(() {
      var filtered = _allScholarships;
      
      // Search filter 
      if (_searchController.text.isNotEmpty) {
        var searchResults = _trie.search(_searchController.text);
        var searchIds = searchResults.map((s) => s.id).toSet();
        
        filtered = filtered.where((s) {
          return searchIds.contains(s.id) ||
              s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              s.description.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      }

      // Category filter
      if (_selectedCategory != 'All') {
        filtered = filtered.where((s) => s.category == _selectedCategory).toList();
      }

      // Amount filter
      if (_minAmount.isNotEmpty) {
        double minAmt = double.tryParse(_minAmount) ?? 0;
        filtered = filtered.where((s) => s.amount >= minAmt).toList();
      }

      _filteredScholarships = filtered;
    });
  }

  void _selectSuggestion(Scholarship scholarship) {
    setState(() {
      _searchController.text = scholarship.name;
      _suggestions = [];
      _filterScholarships();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _minAmount = '';
      _suggestions = [];
      _filteredScholarships = _allScholarships;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            backgroundColor: AppColors.primaryTeal,
            elevation: 0,
            floating: true,
            pinned: true,
            
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SearchBarWidget(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  themeColor: Colors.white,
                ),
              ),
            ),
          ),

          // Suggestions
          if (_suggestions.isNotEmpty)
            SliverToBoxAdapter(
              child: SuggestionListWidget(
                suggestions: _suggestions,
                onSuggestionTap: _selectSuggestion,
                themeColor: AppColors.primaryTeal,
              ),
            ),

          // Filter Controls
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(Icons.filter_list_alt, size: 20),
                      label: Text(
                        _showFilters ? 'Hide Filters' : 'Filters',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: Icon(Icons.refresh, size: 20, color: AppColors.primaryTeal),
                      label: Text(
                        'Reset',
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryTeal, width: 1.5),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          if (_showFilters)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FilterSectionWidget(
                  selectedCategory: _selectedCategory,
                  minAmount: _minAmount,
                  categories: _categories,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _filterScholarships();
                    });
                  },
                  onAmountChanged: (value) {
                    setState(() {
                      _minAmount = value;
                      _filterScholarships();
                    });
                  },
                  themeColor: AppColors.primaryTeal,
                ),
              ),
            ),

          // Results Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                '${_filteredScholarships.length} ${_filteredScholarships.length == 1 ? 'Scholarship' : 'Scholarships'} Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Scholarship Cards
          if (_filteredScholarships.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No scholarships found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Try adjusting your search or filter criteria',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScholarshipCardWidget(
                        scholarship: _filteredScholarships[index],
                        themeColor: AppColors.primaryTeal,
                      ),
                    );
                  },
                  childCount: _filteredScholarships.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}