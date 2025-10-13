import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
<<<<<<< HEAD
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scholarship/pages/Search_Page/screens/scholarship_search_screen.dart';
import 'package:scholarship/pages/chat/chat_page.dart';
>>>>>>> main
import '../services/google_auth_service.dart';
import '../services/firestore_service.dart';

/// ----------------
/// Color Palette
/// ----------------
class AppColors {
  static const Color darkTeal = Color(0xFF009688); // main teal
  static const Color secondaryLight = Color(0xFFB2DFDB);
  static const Color primaryTeal = Color(0xFF00695C);
  static const Color accentGold = Colors.orange;
  static const Color bgLight = Color(0xFFF9F9F9);  // Light white background
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color errorWhite = Color(0xFFF5F5F5);  // Slightly off-white
  static const Color errorRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF555555);
  static const Color scaffoldBackground = Color(0xFFF5F7FA);  // Light grayish white
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
<<<<<<< HEAD
    final TextEditingController phoneController = TextEditingController(text: '+91 9876543210');
    final TextEditingController categoryController = TextEditingController(text: 'General');
    final TextEditingController cgpaController = TextEditingController(text: '9.1');
=======
    final TextEditingController phoneController = TextEditingController(text: _getPhoneNumber());
    final TextEditingController categoryController = TextEditingController(text: _getCategory());
    final TextEditingController cgpaController = TextEditingController(text: _getCGPA());
>>>>>>> main

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
<<<<<<< HEAD
              Icon(Icons.edit, color: AppColors.primaryTeal),
=======
              Icon(Icons.edit, color: AppColors.darkTeal),
>>>>>>> main
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
<<<<<<< HEAD
                backgroundColor: AppColors.primaryTeal,
=======
                backgroundColor: AppColors.darkTeal,
>>>>>>> main
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
<<<<<<< HEAD
=======
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Updating profile...'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }

>>>>>>> main
      // Update Firebase Auth display name
      await _currentUser?.updateDisplayName(name);

      // Update Firestore with additional details
      await FirestoreService.updateUserProfile({
        'displayName': name,
        'phoneNumber': phone,
        'category': category,
        'cgpa': cgpa,
<<<<<<< HEAD
      });

      // Reload user data
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
=======
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Force reload user data from Firestore
      await _loadUserData();
      
      // Force refresh the current user from Firebase Auth
      await _currentUser?.reload();

      // Trigger a rebuild of the profile page with updated data
      if (mounted) {
        setState(() {
          // This will trigger a rebuild with the new data
        });

        // Clear any existing snackbars and show success message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
>>>>>>> main
          ),
        );
      }
    } catch (e) {
      if (mounted) {
<<<<<<< HEAD
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
=======
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Failed to update profile: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
>>>>>>> main
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
      backgroundColor: AppColors.scaffoldBackground,
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (currentPageIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return ScholarshipSearchScreen();
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
          SliverToBoxAdapter(
            child: _buildCustomHeader(),
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
                SizedBox(height: 10),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSmartTools(),
                ),
                SizedBox(height: 20),
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

 

  Widget _buildChatPage() {
    return const ChatPage();      
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
<<<<<<< HEAD
                        colors: [AppColors.primaryTeal, AppColors.primaryTeal.withOpacity(0.6)],
=======
                        colors: [AppColors.darkTeal, AppColors.darkTeal.withOpacity(0.6)],
>>>>>>> main
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
<<<<<<< HEAD
                  leading: Icon(Icons.fingerprint, color: AppColors.primaryTeal),
=======
                  leading: Icon(Icons.fingerprint, color: AppColors.darkTeal),
>>>>>>> main
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
<<<<<<< HEAD
                    _detailRow('Phone', '+91 9876543210'),
                    _detailRow('Category', 'General'),
                    _detailRow('CGPA', '9.1'),
=======
                    _detailRow('Phone', _getPhoneNumber()),
                    _detailRow('Category', _getCategory()),
                    _detailRow('CGPA', _getCGPA()),
>>>>>>> main
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

  String _getPhoneNumber() {
    // Try Firestore data first
    if (_firestoreUserData?['phoneNumber'] != null) {
      return _firestoreUserData!['phoneNumber'];
    }
    // Fallback to Firebase Auth data or default
    return _currentUser?.phoneNumber ?? '+91 9876543210';
  }

  String _getCategory() {
    // Try Firestore data first
    if (_firestoreUserData?['category'] != null) {
      return _firestoreUserData!['category'];
    }
    // Default value
    return 'General';
  }

  String _getCGPA() {
    // Try Firestore data first
    if (_firestoreUserData?['cgpa'] != null) {
      return _firestoreUserData!['cgpa'];
    }
    // Default value
    return '9.1';
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
<<<<<<< HEAD
        backgroundColor: AppColors.primaryTeal,
=======
        backgroundColor: AppColors.darkTeal,
>>>>>>> main
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
<<<<<<< HEAD
              Icon(icon, color: AppColors.primaryTeal),
=======
              Icon(icon, color: AppColors.darkTeal),
>>>>>>> main
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
<<<<<<< HEAD
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
=======
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkTeal)),
>>>>>>> main
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

  Widget _buildCustomHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: [AppColors.darkTeal, AppColors.darkTeal.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Profile and Notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Section
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildHeaderAvatar(),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          _getFirstName(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Notification Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          // Handle notification tap
                          _showNotifications();
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Welcome Message
            Text(
              'Find Your Perfect Scholarship',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Discover opportunities that match your profile',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAvatar() {
    final user = _currentUser;
    final photoUrl = _firestoreUserData?['photoURL'] ?? user?.photoURL;
    final displayName = _getUserDisplayName();
    
    if (photoUrl != null) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildHeaderFallbackAvatar(displayName);
        },
      );
    } else {
      return _buildHeaderFallbackAvatar(displayName);
    }
  }

  Widget _buildHeaderFallbackAvatar(String displayName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getFirstName() {
    final fullName = _getUserDisplayName();
    if (fullName.contains(' ')) {
      return fullName.split(' ')[0];
    }
    return fullName;
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.notifications, color: AppColors.darkTeal),
                SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.darkTeal.withOpacity(0.1),
                child: Icon(Icons.check_circle, color: AppColors.darkTeal),
              ),
              title: Text('Scholarship Application Approved'),
              subtitle: Text('Your AICTE application has been approved'),
              trailing: Text('2h ago', style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Icon(Icons.pending, color: Colors.orange),
              ),
              title: Text('Document Verification Pending'),
              subtitle: Text('Please upload your income certificate'),
              trailing: Text('1d ago', style: TextStyle(color: Colors.grey)),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(Icons.new_releases, color: Colors.blue),
              ),
              title: Text('New Scholarship Available'),
              subtitle: Text('Merit-based scholarship for CS students'),
              trailing: Text('3d ago', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

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
                  color: AppColors.darkTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(item['icon'] as IconData, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 6),
             Text(
  item['label'] as String,
  style: TextStyle(fontSize: 12, color: AppColors.darkTeal),
),

            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.darkTeal,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
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
                    color: AppColors.darkTeal,
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
                      style: TextStyle(color: Colors.white),
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
      const SizedBox(height: 4),  // Reduced from 5
      GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: smartTools.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,  // Reduced from 8
          crossAxisSpacing: 4,  // Reduced from 8
          childAspectRatio: 0.7, // Adjusted from 0.8 to make items more compact
        ),
        itemBuilder: (context, index) {
          final t = smartTools[index];
          return Column(
            mainAxisSize: MainAxisSize.min,  // Added to make the column take minimum space
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 56,  // Reduced from 64
                  height: 56, // Reduced from 64
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)  // Reduced blur
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      t['icon'] as IconData,
                      size: 20,  // Reduced from 24
                      color: AppColors.darkTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),  // Reduced from 6
              Text(
                t['title']!,
                style: const TextStyle(
                  fontSize: 10,  // Reduced from 11
                  color: AppColors.textSecondary,
                  height: 1.1,   // Tighter line height
                ),
                textAlign: TextAlign.center,
                maxLines: 2,     // Ensure text wraps to a second line if needed
                overflow: TextOverflow.ellipsis,
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
                          backgroundColor: AppColors.darkTeal,
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
              colors: [AppColors.darkTeal, AppColors.secondaryLight],
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
                          color: Colors.white,
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
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              isSelected: currentPageIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.search_rounded,
              label: 'Search',
              index: 1,
              isSelected: currentPageIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              index: 2,
              isSelected: currentPageIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
              isSelected: currentPageIndex == 3,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildNavItem({
  required IconData icon,
  required String label,
  required int index,
  required bool isSelected,
}) {
  return Expanded(
    child: InkWell(
      onTap: () {
        setState(() {
          currentPageIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: AppColors.darkTeal.withOpacity(0.1),
      highlightColor: AppColors.darkTeal.withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 8 : 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.darkTeal.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppColors.darkTeal
                    : AppColors.textSecondary,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 12.5 : 11.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? AppColors.darkTeal
                    : AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ),
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
                      color: isSelected ? AppColors.darkTeal : AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.darkTeal : AppColors.secondaryLight,
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.darkTeal.withOpacity(0.3),
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