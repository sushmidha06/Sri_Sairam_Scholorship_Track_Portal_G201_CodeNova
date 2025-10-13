import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../services/google_auth_service.dart';
import '../services/firestore_service.dart';

/// ----------------
/// Color Palette
/// ----------------
class AppColors {
  static const Color primaryTeal = Color(0xFF009688); // main teal
  static const Color secondaryLight = Color(0xFFB2DFDB);
  static const Color darkTeal = Color(0xFF00695C);
  static const Color accentGold = Color(0xFFFFC107);
  static const Color bgLight = Color(0xFFE0F2F1);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF555555);
}

/// ----------------
/// Sample Data Models
/// ----------------
class Scholarship {
  final String title;
  final String eligibility;
  final DateTime deadline;
  final String tag; // New, Closing Soon, Popular

  Scholarship({
    required this.title,
    required this.eligibility,
    required this.deadline,
    this.tag = '',
  });
}

/// ----------------
/// Home Page
/// ----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  String selectedFilter = 'All';
  Map<String, dynamic>? _firestoreUserData;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await FirestoreService.getUserProfile();
      if (mounted) {
        setState(() {
          _firestoreUserData = userData;
        });
        if (userData != null) {
          print('Firestore user data loaded successfully');
        } else {
          print('No Firestore data found, using Firebase Auth fallback');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Continue with Firebase Auth data as fallback
      if (mounted) {
        setState(() {
          _firestoreUserData = null;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await GoogleAuthService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Biometric Authentication for Profile Editing
  Future<void> _authenticateAndEditProfile() async {
    try {
      // Check if biometric authentication is available
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication is not available on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get available biometric types
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No biometric authentication methods are set up'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Perform biometric authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to edit your profile details',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Authentication successful, show profile edit dialog
        _showProfileEditDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show Profile Edit Dialog
  void _showProfileEditDialog() {
    final TextEditingController nameController = TextEditingController(text: _getUserDisplayName());
    final TextEditingController phoneController = TextEditingController(text: '+91 9876543210');
    final TextEditingController categoryController = TextEditingController(text: 'General');
    final TextEditingController cgpaController = TextEditingController(text: '9.1');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primaryTeal),
              SizedBox(width: 8),
              Text('Edit Profile Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: cgpaController,
                  decoration: InputDecoration(
                    labelText: 'CGPA',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grade),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveProfileChanges(
                  nameController.text,
                  phoneController.text,
                  categoryController.text,
                  cgpaController.text,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  /// Save Profile Changes
  Future<void> _saveProfileChanges(String name, String phone, String category, String cgpa) async {
    try {
      // Update Firebase Auth display name
      await _currentUser?.updateDisplayName(name);

      // Update Firestore with additional details
      await FirestoreService.updateUserProfile({
        'displayName': name,
        'phoneNumber': phone,
        'category': category,
        'cgpa': cgpa,
      });

      // Reload user data
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  final List<String> filterOptions = [
    'All',
    'Recommended', 
    'Based on Profile',
    'Previously Viewed',
    'Top Rated'
  ];
  
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allKey = GlobalKey();
  final GlobalKey _recommendedKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _viewedKey = GlobalKey();
  final GlobalKey _topRatedKey = GlobalKey();
  final List<Scholarship> allScholarships = [
    Scholarship(
      title: 'National Merit Scholarship',
      eligibility: 'UG | Merit-based',
      deadline: DateTime.now().add(Duration(days: 8)),
      tag: 'Closing Soon',
    ),
    Scholarship(
      title: 'State Study Grant',
      eligibility: 'SC/ST | PG',
      deadline: DateTime.now().add(Duration(days: 25)),
      tag: 'New',
    ),
    Scholarship(
      title: 'International Excellence Award',
      eligibility: 'UG | International',
      deadline: DateTime.now().add(Duration(days: 40)),
      tag: 'Popular',
    ),
    Scholarship(
      title: 'Research Fellowship Program',
      eligibility: 'PhD | Research',
      deadline: DateTime.now().add(Duration(days: 60)),
      tag: '',
    ),
    Scholarship(
      title: 'Sports Excellence Scholarship',
      eligibility: 'UG/PG | Sports',
      deadline: DateTime.now().add(Duration(days: 35)),
      tag: '',
    ),
  ];

  final List<Scholarship> recommended = [
    Scholarship(
      title: 'National Merit Scholarship',
      eligibility: 'UG | Merit-based',
      deadline: DateTime.now().add(Duration(days: 8)),
      tag: 'Closing Soon',
    ),
    Scholarship(
      title: 'State Study Grant',
      eligibility: 'SC/ST | PG',
      deadline: DateTime.now().add(Duration(days: 25)),
      tag: 'New',
    ),
    Scholarship(
      title: 'International Excellence Award',
      eligibility: 'UG | International',
      deadline: DateTime.now().add(Duration(days: 40)),
      tag: 'Popular',
    ),
  ];

  final List<Scholarship> basedOnProfile = [
    Scholarship(
      title: 'Engineering Excellence Grant',
      eligibility: 'UG | Engineering',
      deadline: DateTime.now().add(Duration(days: 22)),
      tag: 'Perfect Match',
    ),
    Scholarship(
      title: 'Computer Science Innovation Award',
      eligibility: 'UG/PG | CS/IT',
      deadline: DateTime.now().add(Duration(days: 45)),
      tag: 'High Match',
    ),
    Scholarship(
      title: 'STEM Women Empowerment',
      eligibility: 'UG/PG | Female | STEM',
      deadline: DateTime.now().add(Duration(days: 30)),
      tag: 'Recommended',
    ),
  ];

  final List<Scholarship> previouslyViewed = [
    Scholarship(
      title: 'Rural Development Scholarship',
      eligibility: 'UG | Rural Background',
      deadline: DateTime.now().add(Duration(days: 15)),
      tag: 'Previously Viewed',
    ),
    Scholarship(
      title: 'Minority Community Support',
      eligibility: 'UG/PG | Minority',
      deadline: DateTime.now().add(Duration(days: 28)),
      tag: 'Previously Viewed',
    ),
    Scholarship(
      title: 'First Generation College Grant',
      eligibility: 'UG | First Generation',
      deadline: DateTime.now().add(Duration(days: 50)),
      tag: 'Previously Viewed',
    ),
  ];

  final List<Scholarship> topRated = [
    Scholarship(
      title: 'Prime Minister Excellence Award',
      eligibility: 'UG/PG | Top 1%',
      deadline: DateTime.now().add(Duration(days: 90)),
      tag: '★★★★★',
    ),
    Scholarship(
      title: 'National Science Foundation Grant',
      eligibility: 'PG/PhD | Research',
      deadline: DateTime.now().add(Duration(days: 75)),
      tag: '★★★★★',
    ),
    Scholarship(
      title: 'Global Leadership Scholarship',
      eligibility: 'UG/PG | Leadership',
      deadline: DateTime.now().add(Duration(days: 65)),
      tag: '★★★★☆',
    ),
    Scholarship(
      title: 'Innovation Challenge Award',
      eligibility: 'UG/PG | Innovation',
      deadline: DateTime.now().add(Duration(days: 55)),
      tag: '★★★★☆',
    ),
  ];

  final List<Map<String, dynamic>> smartTools = [
    {'title': 'Document\nChecklist', 'icon': Icons.assignment_outlined},
    {'title': 'Eligibility\nChecker', 'icon': Icons.fact_check_outlined},
    {'title': 'Deadline\nTracker', 'icon': Icons.schedule_outlined},
    {'title': 'Chat\nAssistant', 'icon': Icons.chat_bubble_outline},
  ];

  final List<Scholarship> upcoming = [
    Scholarship(
      title: 'Rural Student Support',
      eligibility: 'UG | Income Proof',
      deadline: DateTime.now().add(Duration(days: 3)),
      tag: 'Closing Soon',
    ),
    Scholarship(
      title: 'Women in STEM Grant',
      eligibility: 'UG/PG | Female',
      deadline: DateTime.now().add(Duration(days: 12)),
      tag: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (currentPageIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildSearchPage();
      case 2:
        return _buildChatPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryTeal,
            title: Text(
              'Scholarship Track',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.language, color: Colors.white),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              selectedFilter: selectedFilter,
              filterOptions: filterOptions,
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
                _scrollToSection(filter);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 12),
                _buildCategoryScroll(),
                SizedBox(height: 18),
                
                // All Scholarships Section
                Container(
                  key: _allKey,
                  child: _buildSectionTitle('All Scholarships'),
                ),
                SizedBox(height: 8),
                _buildRecommendedCarousel(allScholarships),
                SizedBox(height: 18),
                
                // Recommended Section
                Container(
                  key: _recommendedKey,
                  child: _buildSectionTitle('Recommended for You'),
                ),
                SizedBox(height: 8),
                _buildRecommendedCarousel(recommended),
                SizedBox(height: 18),
                
                // Based on Profile Section
                Container(
                  key: _profileKey,
                  child: _buildSectionTitle('Based on Your Profile'),
                ),
                SizedBox(height: 8),
                _buildRecommendedCarousel(basedOnProfile),
                SizedBox(height: 18),
                
                // Previously Viewed Section
                Container(
                  key: _viewedKey,
                  child: _buildSectionTitle('Previously Viewed'),
                ),
                SizedBox(height: 8),
                _buildRecommendedCarousel(previouslyViewed),
                SizedBox(height: 18),
                
                // Top Rated Section
                Container(
                  key: _topRatedKey,
                  child: _buildSectionTitle('Top Rated Scholarships'),
                ),
                SizedBox(height: 8),
                _buildRecommendedCarousel(topRated),
                SizedBox(height: 18),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSmartTools(),
                ),
                SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildUpcomingDeadlines(upcoming),
                ),
                SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildApplicationTracker(),
                ),
                SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildCTABanner(),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildSearchPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Scholarships'),
        backgroundColor: AppColors.primaryTeal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search scholarships...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryTeal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Search Filters
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('All Categories', textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondaryLight),
                    ),
                    child: Text('Deadline', textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondaryLight),
                    ),
                    child: Text('Amount', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Search Results
            Expanded(
              child: ListView.builder(
                itemCount: allScholarships.length,
                itemBuilder: (context, index) {
                  final scholarship = allScholarships[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scholarship.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          scholarship.eligibility,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Deadline: ${_formatDate(scholarship.deadline)}',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('View Details', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat Assistant'),
        backgroundColor: AppColors.primaryTeal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // AI Message
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Hello! I\'m your scholarship assistant. I can help you find scholarships, check eligibility, and answer questions about applications. How can I help you today?',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // User Message
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'What scholarships are available for engineering students?',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person, color: AppColors.darkTeal, size: 20),
                      ),
                    ],
                  ),
                ),
                // AI Response
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Great question! I found several engineering scholarships for you:\n\n• Engineering Excellence Grant\n• National Merit Scholarship\n• STEM Women Empowerment\n\nWould you like me to show you the details for any of these?',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chat Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Header with gradient
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.primaryTeal.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.settings, color: Colors.white),
                              Text(
                                'Scholarship Tracker',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.logout, color: Colors.white),
                                onPressed: _signOut,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: _buildUserAvatar(),
                  ),
                ],
              ),

              SizedBox(height: 50),

              // Student name and details
              Column(
                children: [
                  Text(
                    _getUserDisplayName(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('B.Tech - Computer Science', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(_getUserEmail(), style: TextStyle(color: Colors.grey)),
                ],
              ),

              // Dashboard
              _sectionCard(
                title: 'Dashboard',
                icon: Icons.dashboard_rounded,
                content: Column(
                  children: [
                    _dashboardItem('Active Scholarships', '3'),
                    _dashboardItem('Pending Applications', '1'),
                    _dashboardItem('Completed Applications', '5'),
                  ],
                ),
              ),

              // Edit Details
              _sectionCard(
                title: 'Edit Details (Secured)',
                icon: Icons.lock_outline,
                content: ListTile(
                  leading: Icon(Icons.fingerprint, color: AppColors.primaryTeal),
                  title: Text('Use Biometric Authentication'),
                  subtitle: Text('Secure your profile updates'),
                  contentPadding: EdgeInsets.zero,
                  onTap: _authenticateAndEditProfile,
                ),
              ),

              // Basic Details
              _sectionCard(
                title: 'Basic Details',
                icon: Icons.person_outline,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow('Full Name', _getUserDisplayName()),
                    _detailRow('Email', _getUserEmail()),
                    _detailRow('Phone', '+91 9876543210'),
                    _detailRow('Category', 'General'),
                    _detailRow('CGPA', '9.1'),
                  ],
                ),
              ),

              // Application History
              _sectionCard(
                title: 'Application History',
                icon: Icons.history,
                content: Column(
                  children: [
                    _historyItem('AICTE Pragati Scholarship', 'Approved', Colors.green),
                    _historyItem('National Scholarship Portal', 'Pending', Colors.orange),
                    _historyItem('Inspire Scholarship', 'Rejected', Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// ----------------
  /// User Data Methods
  /// ----------------

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String _getUserDisplayName() {
    // Try Firestore data first
    if (_firestoreUserData?['displayName'] != null && 
        _firestoreUserData!['displayName'].toString().isNotEmpty) {
      return _firestoreUserData!['displayName'];
    }
    
    // Fallback to Firebase Auth data
    final user = _currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user?.email != null) {
      // Extract name from email (part before @)
      return user!.email!.split('@')[0].replaceAll('.', ' ').split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    }
    return 'User';
  }

  String _getUserEmail() {
    // Try Firestore data first
    if (_firestoreUserData?['email'] != null) {
      return _firestoreUserData!['email'];
    }
    // Fallback to Firebase Auth data
    return _currentUser?.email ?? 'No email';
  }

  Widget _buildUserAvatar() {
    final user = _currentUser;
    // Try Firestore photo URL first, then Firebase Auth
    final photoUrl = _firestoreUserData?['photoURL'] ?? user?.photoURL;
    final displayName = _getUserDisplayName();
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 46,
        backgroundColor: AppColors.primaryTeal,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null 
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      ),
    );
  }

  /// ----------------
  /// Profile Helper Methods
  /// ----------------

  Widget _sectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _dashboardItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _historyItem(String scholarship, String status, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              scholarship, 
              style: TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// ----------------
  /// Widgets
  /// ----------------


  Widget _buildCategoryScroll() {
    final categories = [
      {'label': 'National', 'icon': Icons.school},
      {'label': 'State', 'icon': Icons.account_balance},
      {'label': 'Institutional', 'icon': Icons.apartment},
      {'label': 'International', 'icon': Icons.public},
      {'label': 'Eligibility', 'icon': Icons.check_circle},
      {'label': 'Deadlines', 'icon': Icons.event},
    ];

    return Container(
      height: 90,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = categories[index];
          return Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(item['icon'] as IconData, color: AppColors.darkTeal),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 6),
             Text(
  item['label'] as String,
  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
),

            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
            color: AppColors.darkTeal, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRecommendedCarousel(List<Scholarship> items) {
    return Container(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        padEnds: false,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final s = items[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 4, 
              right: index == items.length - 1 ? 16 : 4
            ),
            child: _scholarshipCard(s),
          );
        },
      ),
    );
  }

  Widget _scholarshipCard(Scholarship s) {
    final daysLeft = s.deadline.difference(DateTime.now()).inDays;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (s.tag.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.tag,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                )
            ],
          ),
          SizedBox(height: 8),
          Text(
            s.eligibility,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deadline: ${_formatDate(s.deadline)}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Row(
                children: [
                  if (daysLeft <= 5)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '$daysLeft days left',
                        style: TextStyle(color: AppColors.errorRed, fontSize: 12),
                      ),
                    ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: Text(
                      'Apply Now',
                      style: TextStyle(color: AppColors.darkTeal),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmartTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Tools',
          style: TextStyle(
            color: AppColors.darkTeal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: smartTools.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final t = smartTools[index];
            return Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        t['icon'] as IconData,
                        size: 24,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  t['title']!,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingDeadlines(List<Scholarship> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: AppColors.darkTeal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0, // Square aspect ratio
          ),
          itemBuilder: (context, index) {
            final s = items[index];
            final days = s.deadline.difference(DateTime.now()).inDays;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    s.eligibility,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${days}d left',
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size(0, 28),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildApplicationTracker() {
    // Sample counts
    final underReview = 2;
    final approved = 1;
    final rejected = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track Your Applications',
          style: TextStyle(
            color: AppColors.darkTeal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 120, // Fixed height to make it more square
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusBadge('Under Review', underReview, Colors.orange),
              _statusBadge('Approved', approved, Colors.green),
              _statusBadge('Rejected', rejected, Colors.red),
            ],
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text('View All Applications'),
          ),
        )
      ],
    );
  }

  Widget _statusBadge(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCTABanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        
        return Container(
          constraints: BoxConstraints(
            minHeight: isSmallScreen ? 140 : 160,
            maxHeight: isSmallScreen ? 180 : 200,
          ),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryTeal, AppColors.secondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Don\'t miss your next opportunity!',
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: isSmallScreen ? 14 : 16
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        'Sign up & get personalized alerts for scholarships that match your profile.',
                        style: TextStyle(
                          color: Colors.white70, 
                          fontSize: isSmallScreen ? 11 : 13
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 8 : 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Sign Up Free', 
                        style: TextStyle(
                          color: AppColors.darkTeal,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 12),
              // decorative icon
              Container(
                width: isSmallScreen ? 60 : 72,
                height: isSmallScreen ? 60 : 72,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch, 
                  size: isSmallScreen ? 28 : 36, 
                  color: Colors.white,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryTeal,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      currentIndex: currentPageIndex,
      onTap: (index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
    );
  }

  String _formatDate(DateTime dt) {
    // Simple formatting e.g., 12 Oct
    // If you add intl package, you can use DateFormat('d MMM')
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  void _scrollToSection(String filter) {
    GlobalKey? targetKey;
    switch (filter) {
      case 'All':
        targetKey = _allKey;
        break;
      case 'Recommended':
        targetKey = _recommendedKey;
        break;
      case 'Based on Profile':
        targetKey = _profileKey;
        break;
      case 'Previously Viewed':
        targetKey = _viewedKey;
        break;
      case 'Top Rated':
        targetKey = _topRatedKey;
        break;
    }
    
    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

/// ----------------
/// Filter Header Delegate
/// ----------------
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedFilter;
  final List<String> filterOptions;
  final Function(String) onFilterChanged;

  _FilterHeaderDelegate({
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bgLight,
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.secondaryLight,
          ),
          Container(
            height: 59,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: ListView.separated(
              padding: EdgeInsets.only(left: 16, right: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final filter = filterOptions[index];
                final isSelected = filter == selectedFilter;
                return GestureDetector(
                  onTap: () => onFilterChanged(filter),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryTeal : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryTeal : AppColors.secondaryLight,
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ] : [],
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}