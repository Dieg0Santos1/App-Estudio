import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/auth/supabase_auth_provider.dart';
import '../../../shared/presentation/focus_bottom_nav.dart';
import '../../permissions/data/device_permissions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  PermissionSnapshot? _permissions;

  static const _weeklyMinutes = [45, 78, 36, 96, 112, 18, 22];
  static const _recentMaterials = [
    _RecentMaterial(
      title: 'POO_Resumen_Final.pdf',
      subtitle: 'Procesado por IA',
      meta: '2.4 MB',
      color: Color(0xFFE85D75),
      icon: Icons.picture_as_pdf_rounded,
    ),
    _RecentMaterial(
      title: 'Apuntes_Clases_S3.md',
      subtitle: 'Listo para estudiar',
      meta: '1.2 MB',
      color: Color(0xFFE7C948),
      icon: Icons.article_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final snapshot = await ref.read(devicePermissionsProvider).load();
    if (!mounted) {
      return;
    }

    setState(() => _permissions = snapshot);
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(ref);
    final permissionsReady = _permissions?.requiredPermissionsReady ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      bottomNavigationBar: const FocusBottomNav(currentRoute: AppRoute.home),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _HomeTopBar(),
                  const SizedBox(height: 20),
                  _Greeting(firstName: firstName),
                  const SizedBox(height: 18),
                  if (!permissionsReady) ...[
                    _PermissionNotice(
                      onTap: () => context.go(AppRoute.permissions.path),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const _TodaySummary(),
                  const SizedBox(height: 16),
                  _PrimaryStudyButton(
                    onTap: () => context.go(AppRoute.studySession.path),
                  ),
                  const SizedBox(height: 16),
                  _WeeklyProgressCard(
                    minutes: _weeklyMinutes,
                    onDetails: () => context.go(AppRoute.progress.path),
                  ),
                  const SizedBox(height: 16),
                  _RecentMaterialsSection(
                    materials: _recentMaterials,
                    onLibrary: () => context.go(AppRoute.library.path),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final metadata = client?.auth.currentUser?.userMetadata;
    final rawName = metadata?['name']?.toString().trim().replaceAll('%20', ' ');

    if (rawName == null || rawName.isEmpty) {
      return 'Estudiante';
    }

    return rawName.split(RegExp(r'\s+')).first;
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          tooltip: 'Menu',
          color: const Color(0xFF2DD4BF),
        ),
        const Expanded(
          child: Text(
            'Focus',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2DD4BF),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notificaciones',
          color: Color(0xFFEAF6FF),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $firstName',
          style: const TextStyle(
            color: Color(0xFFF1F8FF),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Vamos a estudiar con foco.',
          style: TextStyle(
            color: Color(0xFFB9CBE1),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF102F4F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2B6C8C)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF67E8F9), size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Faltan permisos para bloquear distracciones.',
                  style: TextStyle(
                    color: Color(0xFFE1F7FF),
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF2DD4BF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Racha',
            value: '5 dias',
            icon: Icons.local_fire_department_rounded,
            iconColor: Color(0xFFE9B949),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Hoy',
            value: '2h 15m',
            icon: Icons.timer_outlined,
            iconColor: Color(0xFF67E8F9),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF103456),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF174D75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB9CBE1),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF1F8FF),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryStudyButton extends StatelessWidget {
  const _PrimaryStudyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Nueva sesion'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF27C7B8),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.minutes, required this.onDetails});

  final List<int> minutes;
  final VoidCallback onDetails;

  int get _total => minutes.fold(0, (sum, value) => sum + value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF103456),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF174D75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Progreso semanal',
                  style: TextStyle(
                    color: Color(0xFFF1F8FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDetails,
                child: const Text(
                  'Ver detalle',
                  style: TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WeeklyBars(minutes: minutes),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF082641),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E5A7B)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF67E8F9),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Llevas ${_formatMinutes(_total)} esta semana. Vas 20% por encima de tu objetivo.',
                    style: const TextStyle(
                      color: Color(0xFFE1F7FF),
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int value) {
    final hours = value ~/ 60;
    final minutesLeft = value % 60;
    return '${hours}h ${minutesLeft}m';
  }
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.minutes});

  final List<int> minutes;

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final maxValue = minutes.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 116,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < minutes.length; index++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 360 + index * 55),
                    curve: Curves.easeOutCubic,
                    width: 24,
                    height: 22 + (minutes[index] / maxValue) * 64,
                    decoration: BoxDecoration(
                      color: index == 4
                          ? const Color(0xFF62E6D5)
                          : const Color(0xFF4B9EAA),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _labels[index],
                    style: const TextStyle(
                      color: Color(0xFFB9CBE1),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

class _RecentMaterialsSection extends StatelessWidget {
  const _RecentMaterialsSection({
    required this.materials,
    required this.onLibrary,
  });

  final List<_RecentMaterial> materials;
  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Material reciente',
                style: TextStyle(
                  color: Color(0xFFF1F8FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onLibrary,
              child: const Text(
                'Ver biblioteca',
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final material in materials) ...[
          _RecentMaterialTile(material: material),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecentMaterialTile extends StatelessWidget {
  const _RecentMaterialTile({required this.material});

  final _RecentMaterial material;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(AppRoute.studySession.path),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF103456),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF174D75)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: material.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(material.icon, color: material.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF1F8FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${material.subtitle}  ·  ${material.meta}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB9CBE1),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'Opciones',
                color: const Color(0xFFB9CBE1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentMaterial {
  const _RecentMaterial({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String meta;
  final Color color;
  final IconData icon;
}
