import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_state.dart';
import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/phone_frame.dart';
import 'care_team_screen.dart';
import 'chat_screen.dart';
import 'coping_screen.dart';
import 'export_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'log_flow_screen.dart';
import 'medications_screen.dart';
import 'wheel_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavState>();
    final store = context.watch<DataStore>();

    if (store.loading) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(strokeWidth: 2, color: HavenColors.sageDeep),
        ),
      );
    }

    final screen = switch (nav.current) {
      HavenScreen.home => const HomeScreen(),
      HavenScreen.history => const HistoryScreen(),
      HavenScreen.wheel => const WheelScreen(),
      HavenScreen.log => const LogFlowScreen(),
      HavenScreen.coping => const CopingScreen(),
      HavenScreen.doctors => const CareTeamScreen(),
      HavenScreen.meds => const MedicationsScreen(),
      HavenScreen.export => const ExportScreen(),
      HavenScreen.chat => const ChatScreen(),
    };

    return Stack(
      children: [
        Positioned.fill(child: screen),
        if (nav.showTabs)
          const Positioned(left: 0, right: 0, bottom: 0, child: _BottomNav()),
        if (nav.menuOpen) const _DrawerOverlay(),
      ],
    );
  }
}

// --- Bottom navigation --------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavState>();

    Color tab(HavenScreen s) => nav.current == s ? HavenColors.sageDeep : HavenColors.faint2;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: HavenColors.cream.withValues(alpha: 0.82),
            border: const Border(top: BorderSide(color: HavenColors.borderWarm)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Today',
                  color: tab(HavenScreen.home),
                  onTap: () => nav.go(HavenScreen.home)),
              _NavItem(
                  icon: Icons.insights_rounded,
                  label: 'Patterns',
                  color: tab(HavenScreen.history),
                  onTap: () => nav.go(HavenScreen.history)),
              _CenterLogButton(onTap: () => nav.go(HavenScreen.log)),
              _NavItem(
                  icon: Icons.filter_vintage_outlined,
                  label: 'Wheel',
                  color: tab(HavenScreen.wheel),
                  onTap: () => nav.go(HavenScreen.wheel)),
              _NavItem(
                  icon: Icons.spa_outlined,
                  label: 'Wave',
                  color: HavenColors.muted2,
                  onTap: () => nav.go(HavenScreen.coping)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 5),
            Text(label, style: hank(size: 10.5, weight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _CenterLogButton extends StatelessWidget {
  const _CenterLogButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF82997F), Color(0xFF6C8A72)],
            ),
            boxShadow: [
              BoxShadow(
                color: HavenColors.sageDeep.withValues(alpha: 0.8),
                blurRadius: 18,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add, color: HavenColors.cream, size: 28),
          ),
        ),
      ),
    );
  }
}

// --- Side drawer --------------------------------------------------------------

class _DrawerOverlay extends StatelessWidget {
  const _DrawerOverlay();

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: nav.closeMenu,
            child: Container(color: const Color(0xFF2D2821).withValues(alpha: 0.4)),
          ),
        ),
        const Positioned(top: 0, bottom: 0, left: 0, child: _DrawerPanel()),
      ],
    );
  }
}

class _DrawerPanel extends StatefulWidget {
  const _DrawerPanel();

  @override
  State<_DrawerPanel> createState() => _DrawerPanelState();
}

class _DrawerPanelState extends State<_DrawerPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavState>();
    final auth = context.read<AuthState>();
    final user = auth.user;
    final profileName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
        : (user?.email.split('@').first ?? 'Your space');
    final profileEmail = (user?.email.trim().isNotEmpty ?? false) ? user!.email : 'Private journal';

    final items = [
      (Icons.favorite_border, 'Care team', 'Doctors & contacts', HavenScreen.doctors),
      (Icons.medication_outlined, 'Medications', 'Doses & schedule', HavenScreen.meds),
      (Icons.auto_awesome_outlined, 'Chat with Haven', 'A calm companion', HavenScreen.chat),
      (Icons.download_outlined, 'Export data', 'Share with your team', HavenScreen.export),
    ];

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
      child: Container(
        width: 288,
        color: HavenColors.drawerBg,
        padding: const EdgeInsets.fromLTRB(18, 56, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 20),
              child: Row(
                children: [
                  const HavenLogo(size: 48, radius: 15, strokeScale: 1.08),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: news(size: 18, weight: FontWeight.w500, height: 1.15)),
                        Text(profileEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: hank(size: 12.5, color: HavenColors.muted2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: HavenColors.borderWarm),
            const SizedBox(height: 16),
            ...items.map((it) => _DrawerItem(
                  icon: it.$1,
                  label: it.$2,
                  desc: it.$3,
                  onTap: () => nav.go(it.$4),
                )),
            const Spacer(),
            GestureDetector(
              onTap: () => auth.logout(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 18, color: HavenColors.muted2),
                    const SizedBox(width: 10),
                    Text('Sign out',
                        style: hank(size: 14, weight: FontWeight.w600, color: HavenColors.muted2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem(
      {required this.icon, required this.label, required this.desc, required this.onTap});
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EEE8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF5E7A68)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: hank(size: 15, weight: FontWeight.w600)),
                  Text(desc, style: hank(size: 12.5, color: HavenColors.muted2)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: HavenColors.faint),
          ],
        ),
      ),
    );
  }
}
