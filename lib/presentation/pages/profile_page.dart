import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/bloc/locale_bloc.dart';
import 'package:sport_flutter/presentation/pages/edit_profile_page.dart';
import 'package:sport_flutter/presentation/pages/favorites_page.dart';
import 'package:sport_flutter/presentation/pages/login_page.dart';
import 'package:sport_flutter/presentation/pages/my_posts_page.dart';
import 'package:sport_flutter/presentation/pages/privacy_policy_page.dart';
import 'package:sport_flutter/presentation/pages/reset_password_page.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_4),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return ListView(
              children: [
                _buildUserInfoHeader(context, state.user),
                const Divider(height: 0),
                _buildActionList(context, state.user, l10n),
                const Divider(),
                ListTile(
                  leading: const Icon(Iconsax.information),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ));
                  },
                ),
                const Divider(),
                _buildLogoutButton(context, l10n),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildUserInfoHeader(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? const Icon(Iconsax.profile, size: 50)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  user.bio ?? '这个人很懒，什么都没有留下。', // This can also be localized if needed
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context, User user, AppLocalizations l10n) {
    final List<_ActionItem> items = [
      _ActionItem(
        icon: Iconsax.note_2,
        title: l10n.myPosts,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MyPostsPage(),
          ));
        },
      ),
      _ActionItem(
        icon: Iconsax.star,
        title: l10n.myFavorites,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FavoritesPage(),
          ));
        },
      ),
      _ActionItem(
        icon: Iconsax.global,
        title: l10n.language,
        onTap: () => _showLanguageDialog(context, l10n),
      ),
      _ActionItem(
        icon: Iconsax.edit_2,
        title: l10n.editProfile,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditProfilePage(user: user),
          ));
        },
      ),
      _ActionItem(
        icon: Iconsax.key,
        title: l10n.resetPassword,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ResetPasswordPage(),
          ));
        },
      ),
    ];

    return Column(
      children: items.map((item) {
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: item.onTap,
        );
      }).toList(),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.read<LocaleBloc>().add(const ChangeLocale(Locale('en', '')));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: const Text('中文'),
                onTap: () {
                  context.read<LocaleBloc>().add(const ChangeLocale(Locale('zh', 'CN')));
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.logout),
              content: Text(l10n.logoutConfirmation),
              actions: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: Text(l10n.confirmLogout),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                ),
              ],
            ),
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromRGBO(255, 0, 0, 0.1),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(l10n.logout),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _ActionItem({required this.icon, required this.title, required this.onTap});
}
