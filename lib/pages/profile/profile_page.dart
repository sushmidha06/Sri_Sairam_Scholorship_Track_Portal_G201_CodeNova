// Update the imports and class definition
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarship/theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userData;

  const ProfilePage({
    Key? key,
    required this.user,
    required this.userData,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userData = widget.userData ?? {};
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.darkTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(Icons.person, size: 50, color: Colors.white)
                                : null,
                            backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTeal,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Add any additional user stats or info here
                    ],
                  ),
                ),

                // Profile Sections
                _buildSection(
                  title: 'Account Information',
                  icon: Icons.account_circle_outlined,
                  children: [
                    _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? ''),
                    _buildInfoRow(Icons.phone_android_outlined, 'Phone', userData['phone'] ?? 'Not set'),
                    _buildInfoRow(Icons.school_outlined, 'Education', userData['education'] ?? 'Not set'),
                    _buildInfoRow(Icons.work_outline, 'Category', userData['category'] ?? 'Not set'),
                  ],
                ),

                _buildSection(
                  title: 'Preferences',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildPreferenceSwitch('Email Notifications', true),
                    _buildPreferenceSwitch('Push Notifications', true),
                    _buildPreferenceSwitch('Dark Mode', false),
                  ],
                ),

                _buildSection(
                  title: 'Account Actions',
                  icon: Icons.security_outlined,
                  children: [
                    _buildActionButton(
                      'Edit Profile',
                      Icons.edit_outlined,
                      onPressed: () {
                        // TODO: Navigate to edit profile
                      },
                    ),
                    _buildActionButton(
                      'Change Password',
                      Icons.lock_outline,
                      onPressed: () {
                        // TODO: Navigate to change password
                      },
                    ),
                    _buildActionButton(
                      'Sign Out',
                      Icons.logout,
                      isDestructive: true,
                      onPressed: () {
                        // TODO: Handle sign out
                      },
                    ),
                  ],
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryTeal, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSwitch(String title, bool value) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      value: value,
      onChanged: (bool newValue) {
        // TODO: Handle preference change
      },
      activeColor: AppColors.primaryTeal,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon, {
    bool isDestructive = false,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primaryTeal,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onPressed,
    );
  }
}