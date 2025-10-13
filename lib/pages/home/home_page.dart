// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:scholarship/pages/chat/chat_page.dart';
// import 'package:scholarship/theme/app_colors.dart';
// import 'package:scholarship/models/scholarship_model.dart';
// import '../profile/profile_page.dart';
// import 'home_content.dart';
// import '../../services/google_auth_service.dart';
// import '../../services/firestore_service.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _currentPageIndex = 0;
//   String _selectedFilter = 'All';
//   Map<String, dynamic>? _firestoreUserData;
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   final ScrollController _scrollController = ScrollController();
  
//   final Map<GlobalKey, String> _filterKeys = {
//     GlobalKey(): 'All',
//     GlobalKey(): 'Recommended',
//     GlobalKey(): 'Based on Profile',
//     GlobalKey(): 'Previously Viewed',
//     GlobalKey(): 'Top Rated',
//   };

//   final List<Scholarship> _allScholarships = [
//     Scholarship(
//       title: 'National Merit Scholarship',
//       eligibility: 'UG | Merit-based',
//       deadline: DateTime.now().add(const Duration(days: 8)),
//       tag: 'Closing Soon',
//     ),
//     Scholarship(
//       title: 'State Study Grant',
//       eligibility: 'SC/ST | PG',
//       deadline: DateTime.now().add(const Duration(days: 25)),
//       tag: 'New',
//     ),
//     Scholarship(
//       title: 'International Excellence Award',
//       eligibility: 'UG | International',
//       deadline: DateTime.now().add(const Duration(days: 40)),
//       tag: 'Popular',
//     ),
//     Scholarship(
//       title: 'Research Fellowship Program',
//       eligibility: 'PhD | Research',
//       deadline: DateTime.now().add(const Duration(days: 60)),
//       tag: '',
//     ),
//     Scholarship(
//       title: 'Sports Excellence Scholarship',
//       eligibility: 'UG/PG | Sports',
//       deadline: DateTime.now().add(const Duration(days: 35)),
//       tag: '',
//     ),
//   ];

//   List<Scholarship> get _recommendedScholarships => _allScholarships
//       .where((s) => s.tag.isNotEmpty)
//       .toList();

//   User? get _currentUser => FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final userData = await FirestoreService.getUserProfile();
//       if (mounted) {
//         setState(() {
//           _firestoreUserData = userData;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _firestoreUserData = null;
//         });
//       }
//     }
//   }

//   Future<void> _signOut() async {
//     try {
//       await GoogleAuthService.signOut();
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar(
//           'Error signing out',
//           Icons.error_outline,
//           Colors.red,
//         );
//       }
//     }
//   }

//   Future<void> _authenticateAndEditProfile() async {
//     try {
//       final bool isAvailable = await _localAuth.canCheckBiometrics;
//       final bool isDeviceSupported = await _localAuth.isDeviceSupported();

//       if (!isAvailable || !isDeviceSupported) {
//         if (mounted) {
//           _showSnackBar(
//             'Biometric authentication unavailable',
//             Icons.fingerprint,
//             Colors.orange,
//           );
//         }
//         _showProfileEditDialog();
//         return;
//       }

//       final bool didAuthenticate = await _localAuth.authenticate(
//         localizedReason: 'Please authenticate to edit your profile',
//         options: const AuthenticationOptions(
//           biometricOnly: false,
//           stickyAuth: true,
//         ),
//       );

//       if (didAuthenticate) {
//         _showProfileEditDialog();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar(
//           'Authentication error: ${e.toString()}',
//           Icons.error_outline,
//           Colors.red,
//         );
//       }
//     }
//   }

//   void _showProfileEditDialog() {
//     final TextEditingController nameController = TextEditingController(
//       text: _firestoreUserData?['displayName'] ?? _currentUser?.displayName ?? '',
//     );
//     final TextEditingController phoneController = TextEditingController(
//       text: _firestoreUserData?['phoneNumber'] ?? '',
//     );
//     final TextEditingController categoryController = TextEditingController(
//       text: _firestoreUserData?['category'] ?? '',
//     );
//     final TextEditingController cgpaController = TextEditingController(
//       text: _firestoreUserData?['cgpa']?.toString() ?? '',
//     );

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           elevation: 8,
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 500),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryTeal.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.edit_rounded,
//                         color: AppColors.primaryTeal,
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Edit Profile',
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: -0.5,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Update your personal information',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: const Icon(Icons.close),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 28),
//                 SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildTextField(
//                         controller: nameController,
//                         label: 'Full Name',
//                         icon: Icons.person_outline_rounded,
//                         hint: 'Enter your full name',
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTextField(
//                         controller: phoneController,
//                         label: 'Phone Number',
//                         icon: Icons.phone_outlined,
//                         hint: 'Enter your phone number',
//                         keyboardType: TextInputType.phone,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTextField(
//                         controller: categoryController,
//                         label: 'Category',
//                         icon: Icons.category_outlined,
//                         hint: 'e.g., General, OBC, SC/ST',
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTextField(
//                         controller: cgpaController,
//                         label: 'CGPA',
//                         icon: Icons.school_outlined,
//                         hint: 'Enter your CGPA',
//                         keyboardType: TextInputType.number,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           side: BorderSide(color: Colors.grey.shade300),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       flex: 2,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           _saveProfileChanges(
//                             nameController.text,
//                             phoneController.text,
//                             categoryController.text,
//                             cgpaController.text,
//                           );
//                           Navigator.of(context).pop();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primaryTeal,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.save_rounded, size: 18),
//                             SizedBox(width: 8),
//                             Text(
//                               'Save Changes',
//                               style: TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String hint,
//     TextInputType? keyboardType,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//             letterSpacing: 0.2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(
//               color: Colors.grey.shade400,
//               fontWeight: FontWeight.w400,
//             ),
//             prefixIcon: Icon(icon, size: 20, color: AppColors.primaryTeal),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _saveProfileChanges(String name, String phone, String category, String cgpa) async {
//     try {
//       if (mounted) {
//         _showSnackBar(
//           'Updating profile...',
//           Icons.refresh_rounded,
//           Colors.blue,
//           showProgress: true,
//         );
//       }

//       await _currentUser?.updateDisplayName(name);

//       await FirestoreService.updateUserProfile({
//         'displayName': name,
//         'phoneNumber': phone,
//         'category': category,
//         'cgpa': cgpa,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       await _loadUserData();
//       await _currentUser?.reload();

//       if (mounted) {
//         setState(() {});

//         ScaffoldMessenger.of(context).clearSnackBars();
//         _showSnackBar(
//           'Profile updated successfully!',
//           Icons.check_circle_rounded,
//           Colors.green,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).clearSnackBars();
//         _showSnackBar(
//           'Failed to update profile',
//           Icons.error_outline_rounded,
//           Colors.red,
//         );
//       }
//     }
//   }

//   void _showSnackBar(String message, IconData icon, Color color, {bool showProgress = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             if (showProgress)
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             else
//               Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         margin: const EdgeInsets.all(16),
//         duration: Duration(seconds: showProgress ? 2 : 3),
//       ),
//     );
//   }

//   void _onFilterChanged(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentPageIndex,
//         children: [
//           HomeContent(
//             recommendedScholarships: _recommendedScholarships,
//             allScholarships: _allScholarships,
//             selectedFilter: _selectedFilter,
//             onFilterChanged: _onFilterChanged,
//             scrollController: _scrollController,
//             filterKeys: _filterKeys,
//           ),
//           const ChatPage(),
//           ProfilePage(
//             user: _currentUser,
//             userData: _firestoreUserData ?? {},
//             onSignOut: _signOut,
//             onEditProfile: _authenticateAndEditProfile,
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: NavigationBar(
//           selectedIndex: _currentPageIndex,
//           onDestinationSelected: (index) {
//             setState(() {
//               _currentPageIndex = index;
//             });
//           },
//           backgroundColor: Colors.white,
//           indicatorColor: AppColors.primaryTeal.withOpacity(0.15),
//           elevation: 0,
//           height: 70,
//           labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
//           destinations: const [
//             NavigationDestination(
//               icon: Icon(Icons.home_outlined),
//               selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryTeal),
//               label: 'Home',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.chat_bubble_outline_rounded),
//               selectedIcon: Icon(Icons.chat_rounded, color: AppColors.primaryTeal),
//               label: 'Assistant',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.person_outline_rounded),
//               selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryTeal),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }