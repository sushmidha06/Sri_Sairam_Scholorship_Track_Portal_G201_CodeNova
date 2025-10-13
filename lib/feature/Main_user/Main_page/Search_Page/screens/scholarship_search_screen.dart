// ==================== screens/scholarship_search_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/data/scholarship_data.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/models/scholarship.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/utils/trie.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/widgets/filter_section_widget.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/widgets/scholarship_card_widget.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/widgets/search_bar_widget.dart';
import 'package:scholarship/feature/Main_user/Main_page/Search_Page/widgets/suggestion_list_widget.dart';

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
      backgroundColor: Colors.white,
      
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              
              // Search Bar
              SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                themeColor: themeColor,
              ),
              
              // Suggestions
              if (_suggestions.isNotEmpty)
                SuggestionListWidget(
                  suggestions: _suggestions,
                  onSuggestionTap: _selectSuggestion,
                  themeColor: themeColor,
                ),
              
              SizedBox(height: 16),
              
              // Filter Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    label: Text(
                      _showFilters ? 'Hide Filters' : 'Show Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor, width: 2),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Reset All',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Filters
              if (_showFilters)
                FilterSectionWidget(
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
                  themeColor: themeColor,
                ),
              
              if (_showFilters) SizedBox(height: 16),
              
              // Results Count
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Found ${_filteredScholarships.length} scholarship${_filteredScholarships.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Scholarship Cards
              if (_filteredScholarships.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No scholarships found matching your criteria.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search term.',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...(_filteredScholarships.map((scholarship) {
                  return ScholarshipCardWidget(
                    scholarship: scholarship,
                    themeColor: themeColor,
                  );
                }).toList()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}