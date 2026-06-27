import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/constants.dart';
import '../state/auth_state.dart';
import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();
    final nav = context.read<NavState>();
    final user = context.read<AuthState>().user;

    final now = DateTime.now();
    final hour = now.hour;
    final greetBase = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
    final firstName = (user?.name.trim().split(' ').first ?? '');
    final greeting = firstName.isNotEmpty ? '$greetBase, $firstName.' : '$greetBase.';
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    final last = store.lastEntry;
    final lastMeta = last != null ? stateMeta(last.state) : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 108),
      children: [
        FadeUp(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HamburgerButton(onTap: nav.openMenu),
              const SizedBox(height: 18),
              Text(dateStr.toUpperCase(),
                  style: hank(size: 13, color: HavenColors.muted2, letterSpacing: 1.8)),
              const SizedBox(height: 8),
              Text(greeting, style: news(size: 33, height: 1.15, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('How are you arriving in this moment?',
                  style: hank(size: 16, height: 1.5, color: HavenColors.muted)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FadeUp(delay: const Duration(milliseconds: 50), child: _PrimaryActions(nav: nav)),
        const SizedBox(height: 24),
        FadeUp(
          delay: const Duration(milliseconds: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Today at a glance'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(big: '${store.todayCount}', label: 'moments\nlogged')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'current\nstate',
                      badge: lastMeta == null
                          ? null
                          : StateBadge(
                              code: lastMeta.code, color: lastMeta.color, size: 30, radius: 9, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(big: '${last?.intensity ?? '—'}', label: 'last\nintensity')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FadeUp(
          delay: const Duration(milliseconds: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Eyebrow('Recent moments'),
                  GestureDetector(
                    onTap: () => nav.go(HavenScreen.history),
                    behavior: HitTestBehavior.opaque,
                    child: Text('See patterns',
                        style: hank(size: 13, weight: FontWeight.w600, color: HavenColors.sageDeep)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...store.recent.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecentRow(item: e),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FadeUp(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('"The urge is a wave. You are the one who watches it pass."',
                textAlign: TextAlign.center,
                style: news(size: 16, height: 1.5, italic: true, color: HavenColors.muted2)),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.nav});
  final NavState nav;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF82997F), Color(0xFF6C8A72)],
        ),
        boxShadow: [
          BoxShadow(
            color: HavenColors.sageDeep.withValues(alpha: 0.7),
            blurRadius: 28,
            spreadRadius: -14,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Something stirring? You don't have to carry it alone.",
              style: news(size: 19, height: 1.35, color: HavenColors.cream)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SoftButton(
                  label: 'Log a moment',
                  filled: true,
                  onTap: () => nav.go(HavenScreen.log),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SoftButton(
                  label: 'Ride the wave',
                  filled: false,
                  onTap: () => nav.go(HavenScreen.coping),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.label, required this.filled, required this.onTap});
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? HavenColors.cream : HavenColors.cream.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(15),
          border: filled ? null : Border.all(color: HavenColors.cream.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(label,
              style: hank(
                  size: 14,
                  weight: FontWeight.w600,
                  color: filled ? const Color(0xFF3F5945) : HavenColors.cream)),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({this.big, required this.label, this.badge});
  final String? big;
  final String label;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return HavenCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null)
            badge!
          else
            Text(big ?? '', style: news(size: 30, height: 1.0)),
          const SizedBox(height: 7),
          Text(label, style: hank(size: 12, weight: FontWeight.w500, height: 1.2, color: HavenColors.muted)),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item});
  final RecentItem item;

  @override
  Widget build(BuildContext context) {
    return HavenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          StateBadge(code: item.code, color: item.color),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.trigger, style: hank(size: 14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${item.when} · ${item.place}',
                    style: hank(size: 12.5, color: HavenColors.muted2)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.intensity}', style: news(size: 22, height: 1.0, color: item.intColor)),
              Text('INTENSITY',
                  style: hank(size: 10, weight: FontWeight.w500, color: HavenColors.faint, letterSpacing: 0.8)),
            ],
          ),
        ],
      ),
    );
  }
}
