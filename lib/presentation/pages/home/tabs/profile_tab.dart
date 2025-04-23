import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_state.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_typography.dart';
import '../../auth/login_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, user),
                  _buildStatsSection(user),
                  _buildMenuSection(context),
                ],
              ),
            );
          }

          return const Center(child: Text('Failed to load profile'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child:
                user.photoUrl == null
                    ? Text(
                      user.displayName[0].toUpperCase(),
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (user.isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Premium Member',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to premium screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('Upgrade to Premium'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Start Weight',
            '${user.currentWeight ?? 0} kg',
            Icons.flag,
          ),
          _buildStatItem(
            'Current Weight',
            '${user.currentWeight ?? 0} kg',
            Icons.monitor_weight,
          ),
          _buildStatItem(
            'Goal Weight',
            '${user.targetWeight ?? 0} kg',
            Icons.emoji_events,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to edit profile
            },
          ),
          _buildMenuItem(
            icon: Icons.fitness_center,
            title: 'Goals & Preferences',
            onTap: () {
              // TODO: Navigate to goals screen
            },
          ),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              // TODO: Navigate to notifications settings
            },
          ),
          _buildMenuItem(
            icon: Icons.security,
            title: 'Privacy & Security',
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          _buildMenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              // TODO: Navigate to help screen
            },
          ),
          _buildMenuItem(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              // TODO: Navigate to about screen
            },
          ),
          const Divider(height: 32),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Log Out',
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(const SignOutRequested());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
