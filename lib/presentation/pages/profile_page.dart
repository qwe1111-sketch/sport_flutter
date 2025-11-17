import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/domain/entities/user.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/pages/edit_profile_page.dart';
import 'package:sport_flutter/presentation/pages/my_posts_page.dart';
import 'package:sport_flutter/presentation/pages/favorites_page.dart'; // New

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return ListView(
              children: [
                _buildUserInfoHeader(context, state.user),
                const Divider(height: 0),
                _buildGridActions(context, state.user),
                const Divider(),
                _buildLogoutButton(context),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
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
                ? const Icon(Icons.person, size: 50)
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
                  user.bio ?? '这个人很懒，什么都没有留下。',
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

  Widget _buildGridActions(BuildContext context, User user) {
    final List<_GridItem> items = [
      _GridItem(
        icon: Icons.article_outlined,
        title: '我的帖子',
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const MyPostsPage(),
          ));
        },
      ),
      _GridItem(
        icon: Icons.favorite_border,
        title: '我的收藏',
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const FavoritesPage(),
          ));
        },
      ),
      _GridItem(icon: Icons.history, title: '浏览历史', onTap: () {}),
      _GridItem(
        icon: Icons.edit_outlined,
        title: '编辑资料',
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => EditProfilePage(user: user),
          ));
        },
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.grey.shade300, size: 30),
              const SizedBox(height: 8),
              Text(item.title, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextButton(
        onPressed: () {
          // TODO: Implement logout logic
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('退出登录'),
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _GridItem({required this.icon, required this.title, required this.onTap});
}
