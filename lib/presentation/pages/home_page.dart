import 'package:flutter/material.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/pages/community_page.dart';
import 'package:sport_flutter/presentation/pages/profile_page.dart';
import 'package:sport_flutter/presentation/pages/videos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // By creating the pages here and not marking them as 'const', we ensure
  // they are instantiated once and get a correct BuildContext.
  // Using 'late' defers initialization until they are first accessed.
  late final List<Widget> _widgetOptions = [
    const VideosPage(),
    const CommunityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home, // FIX: Use localization
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: l10n.community, // FIX: Use localization
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile, // FIX: Use localization
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
