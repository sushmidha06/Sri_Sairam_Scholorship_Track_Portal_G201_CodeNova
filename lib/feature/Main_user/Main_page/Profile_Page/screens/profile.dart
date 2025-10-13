import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:scholarship/feature/Main_user/Main_page/Home_page/services/firebase_service.dart';
import 'package:scholarship/feature/Main_user/Main_page/Home_page/services/google_auth_service.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  Map<String, dynamic>? _firestoreUserData;
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _firestoreUserData = null;
          _isLoading = false;
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

  Future<void> _authenticateAndEditProfile() async {
    try {
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

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to edit your profile details',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _showProfileEditDialog();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed'),
            backgroundColor: Colors.red,
          ),
        );
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

  void _showProfileEditDialog() {
    final TextEditingController nameController = TextEditingController(text: _getUserDisplayName());
    final TextEditingController phoneController = TextEditingController(
        text: _firestoreUserData?['phoneNumber'] ?? '+91 9876543210');
    final TextEditingController categoryController = TextEditingController(
        text: _firestoreUserData?['category'] ?? 'General');
    final TextEditingController cgpaController = TextEditingController(
        text: _firestoreUserData?['cgpa']?.toString() ?? '9.1');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.teal),
              const SizedBox(width: 8),
              const Text('Edit Profile Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cgpaController,
                  decoration: const InputDecoration(
                    labelText: 'CGPA',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfileChanges(String name, String phone, String category, String cgpa) async {
    try {
      await _currentUser?.updateDisplayName(name);

      await FirestoreService.updateUserProfile({
        'displayName': name,
        'phoneNumber': phone,
        'category': category,
        'cgpa': cgpa,
      });

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

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String _getUserDisplayName() {
    if (_firestoreUserData?['displayName'] != null && 
        _firestoreUserData!['displayName'].toString().isNotEmpty) {
      return _firestoreUserData!['displayName'];
    }
    
    final user = _currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user?.email != null) {
      return user!.email!.split('@')[0].replaceAll('.', ' ').split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
          .join(' ');
    }
    return 'User';
  }

  String _getUserEmail() {
    if (_firestoreUserData?['email'] != null) {
      return _firestoreUserData!['email'];
    }
    return _currentUser?.email ?? 'No email';
  }

  Widget _buildUserAvatar() {
    final photoUrl = _firestoreUserData?['photoURL'] ?? _currentUser?.photoURL;
    final displayName = _getUserDisplayName();
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 46,
        backgroundColor: Colors.teal,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null 
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _dashboardItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyItem(String scholarship, String status, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              scholarship,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // Header with gradient
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF009688), Color(0x99009688)],
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
                              const Icon(Icons.settings, color: Colors.white),
                              const Text(
                                'Scholarship Tracker',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, color: Colors.white),
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

              const SizedBox(height: 50),

              // Student name and details
              Column(
                children: [
                  Text(
                    _getUserDisplayName(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('B.Tech - Computer Science', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text(_getUserEmail(), style: TextStyle(color: Colors.grey.shade600)),
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
                  leading: const Icon(Icons.fingerprint, color: Colors.teal),
                  title: const Text('Use Biometric Authentication'),
                  subtitle: const Text('Secure your profile updates'),
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
                    _detailRow('Phone', _firestoreUserData?['phoneNumber'] ?? '+91 9876543210'),
                    _detailRow('Category', _firestoreUserData?['category'] ?? 'General'),
                    _detailRow('CGPA', _firestoreUserData?['cgpa']?.toString() ?? '9.1'),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}