import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 0;
  late final Future<Map<String, dynamic>?> _profileFuture;

  static const _titles = ['Overview', 'Sessions', 'Device', 'Profile'];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.history_rounded,
    Icons.watch_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return snapshot.data();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final rawName = profile?['fullName'];

        final name = rawName is String && rawName.trim().isNotEmpty
            ? rawName.trim()
            : 'Patient';

        final email = FirebaseAuth.instance.currentUser?.email ?? '';

        return LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 850;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: Row(
                children: [
                  if (desktop)
                    _DesktopSidebar(
                      selectedIndex: _selectedIndex,
                      name: name,
                      email: email,
                      onSelect: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      onSignOut: _signOut,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        _TopBar(
                          title: _titles[_selectedIndex],
                          desktop: desktop,
                          onSignOut: _signOut,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: desktop ? 36 : 18,
                              vertical: desktop ? 30 : 22,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1120,
                                ),
                                child: _buildPage(
                                  name: name,
                                  email: email,
                                  profile: profile,
                                  profileLoading:
                                      snapshot.connectionState ==
                                      ConnectionState.waiting,
                                  profileError: snapshot.hasError,
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
              bottomNavigationBar: desktop
                  ? null
                  : NavigationBar(
                      backgroundColor: AppColors.white,
                      indicatorColor: AppColors.tealLight,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: List.generate(
                        _titles.length,
                        (index) => NavigationDestination(
                          icon: Icon(_icons[index]),
                          selectedIcon: Icon(
                            _icons[index],
                            color: AppColors.teal,
                          ),
                          label: _titles[index],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildPage({
    required String name,
    required String email,
    required Map<String, dynamic>? profile,
    required bool profileLoading,
    required bool profileError,
  }) {
    switch (_selectedIndex) {
      case 0:
        return _OverviewPage(
          name: name,
          onOpenSessions: () {
            setState(() => _selectedIndex = 1);
          },
          onOpenDevice: () {
            setState(() => _selectedIndex = 2);
          },
        );
      case 1:
        return const _SessionsPage();
      case 2:
        return const _DevicePage();
      case 3:
        return _ProfilePage(
          name: name,
          email: email,
          profile: profile,
          loading: profileLoading,
          hasError: profileError,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final String name;
  final String email;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.name,
    required this.email,
    required this.onSelect,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Overview', 'Sessions', 'Device', 'Profile'];
    const icons = [
      Icons.dashboard_outlined,
      Icons.history_rounded,
      Icons.watch_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      width: 252,
      color: AppColors.midnight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 30, 20, 38),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF7BD6D0),
                    size: 30,
                  ),
                  SizedBox(width: 11),
                  Text(
                    'GaitSense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'PATIENT WORKSPACE',
                style: TextStyle(
                  color: Color(0xFF91A4B7),
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(labels.length, (index) {
              final selected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 3,
                ),
                child: Material(
                  color: selected
                      ? const Color(0xFF35475B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelect(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icons[index],
                            size: 21,
                            color: selected
                                ? const Color(0xFF7BD6D0)
                                : const Color(0xFFB8C5D1),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFFB8C5D1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            const Divider(color: Color(0xFF35475B)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: const Color(0xFF35475B),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: Color(0xFF7BD6D0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF91A4B7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
              child: TextButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD5DFE8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool desktop;
  final VoidCallback onSignOut;

  const _TopBar({
    required this.title,
    required this.desktop,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: desktop ? 36 : 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!desktop) ...[
            const Icon(Icons.monitor_heart_outlined, color: AppColors.teal),
            const SizedBox(width: 10),
          ],
          Text(
            desktop ? title : 'GaitSense',
            style: const TextStyle(
              color: AppColors.midnight,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (!desktop)
            IconButton(
              tooltip: 'Sign out',
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          if (desktop)
            const Text(
              'PATIENT PORTAL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  final String name;
  final VoidCallback onOpenSessions;
  final VoidCallback onOpenDevice;

  const _OverviewPage({
    required this.name,
    required this.onOpenSessions,
    required this.onOpenDevice,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('YOUR OVERVIEW'),
        const SizedBox(height: 8),
        Text(
          'Welcome back, $name',
          style: TextStyle(
            color: AppColors.midnight,
            fontSize: wide ? 30 : 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your walking activity and wearable information, all in one place.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 26),
        _DeviceHero(onOpenDevice: onOpenDevice),
        const SizedBox(height: 24),
        const _SectionTitle('Activity overview'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 570;

            if (twoColumns) {
              return const Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Freezing events',
                      icon: Icons.directions_walk_rounded,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _MetricCard(
                      title: 'Walking sessions',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _MetricCard(
                  title: 'Freezing events',
                  icon: Icons.directions_walk_rounded,
                ),
                SizedBox(height: 12),
                _MetricCard(
                  title: 'Walking sessions',
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _RecentActivity(onOpenSessions: onOpenSessions),
      ],
    );
  }
}

class _DeviceHero extends StatelessWidget {
  final VoidCallback onOpenDevice;

  const _DeviceHero({required this.onOpenDevice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.watch_outlined, color: Color(0xFF7BD6D0)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Wearable device',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _StatusPill('Not connected'),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'Your device is not linked yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Device status and monitoring information will appear here '
            'after your wearable is connected to GaitSense.',
            style: TextStyle(
              color: Color(0xFFC3D0DB),
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 19),
          OutlinedButton.icon(
            onPressed: onOpenDevice,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('View device details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF718394)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _MetricCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.teal),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '—',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: AppColors.midnight,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final VoidCallback onOpenSessions;

  const _RecentActivity({required this.onOpenSessions});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('Recent sessions')),
              TextButton(
                onPressed: onOpenSessions,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const _EmptyState(
            icon: Icons.event_note_outlined,
            title: 'No sessions recorded',
            description:
                'Your walking sessions will appear here when monitoring data is available.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SessionsPage extends StatelessWidget {
  const _SessionsPage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow('ACTIVITY HISTORY'),
        SizedBox(height: 8),
        _PageHeading(
          title: 'Walking sessions',
          subtitle: 'Review your recorded monitoring sessions.',
        ),
        SizedBox(height: 24),
        _WhiteCard(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 45),
            child: _EmptyState(
              icon: Icons.history_rounded,
              title: 'No sessions available',
              description:
                  'Recorded sessions will appear here once your wearable begins sending data.',
            ),
          ),
        ),
      ],
    );
  }
}

class _DevicePage extends StatelessWidget {
  const _DevicePage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow('WEARABLE MANAGEMENT'),
        SizedBox(height: 8),
        _PageHeading(
          title: 'Your wearable',
          subtitle: 'View device connectivity and monitoring status.',
        ),
        SizedBox(height: 24),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Device connection'),
              SizedBox(height: 24),
              _DetailRow(
                icon: Icons.link_off_rounded,
                label: 'Connection',
                value: 'Not connected',
              ),
              Divider(height: 32),
              _DetailRow(
                icon: Icons.sensors_off_outlined,
                label: 'Monitoring',
                value: 'Unavailable',
              ),
              Divider(height: 32),
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Last seen',
                value: '—',
              ),
              SizedBox(height: 22),
              Text(
                'Device information will update when the ESP32 is '
                'integrated with Firebase.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final Map<String, dynamic>? profile;
  final bool loading;
  final bool hasError;

  const _ProfilePage({
    required this.name,
    required this.email,
    required this.profile,
    required this.loading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final role = profile?['role'];
    final createdAt = profile?['createdAt'];

    String joined = 'Unavailable';

    if (createdAt is Timestamp) {
      final date = createdAt.toDate();
      joined = '${date.day}/${date.month}/${date.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('ACCOUNT DETAILS'),
        const SizedBox(height: 8),
        const _PageHeading(
          title: 'My profile',
          subtitle: 'Your GaitSense account information.',
        ),
        const SizedBox(height: 24),
        _WhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.tealLight,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'P',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.midnight,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (loading)
                const LinearProgressIndicator()
              else if (hasError)
                const Text(
                  'Could not load your profile details.',
                  style: TextStyle(color: AppColors.error),
                )
              else ...[
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Full name',
                  value: name,
                ),
                const Divider(height: 32),
                _DetailRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: email,
                ),
                const Divider(height: 32),
                _DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Account type',
                  value: role is String ? role : 'Patient',
                ),
                const Divider(height: 32),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Joined',
                  value: joined,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 21),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.midnight,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF35475B),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFDCE6ED),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: const BoxDecoration(
              color: AppColors.tealLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.teal, size: 27),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.midnight,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;

  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.teal,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.midnight,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.midnight,
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}
