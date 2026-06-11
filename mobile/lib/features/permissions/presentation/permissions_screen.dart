import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/device_permissions.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  PermissionSnapshot? _snapshot;
  PermissionKind? _expandedKind;
  PermissionKind? _activeStep;
  bool _isRefreshing = true;
  bool _isHandlingAction = false;

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
    setState(() => _isRefreshing = true);
    final snapshot = await ref.read(devicePermissionsProvider).load();

    if (!mounted) {
      return;
    }

    final nextPending = _firstPendingRequired(snapshot);
    final expandedStillPending =
        _expandedKind != null &&
        _isPending(snapshot, _expandedKind!) &&
        _expandedKind != PermissionKind.files &&
        _expandedKind != PermissionKind.accessibility;

    setState(() {
      _snapshot = snapshot;
      _isRefreshing = false;
      _activeStep = nextPending;
      _expandedKind = expandedStillPending
          ? _expandedKind
          : nextPending ?? PermissionKind.usageAccess;
    });
  }

  Future<void> _handlePrimaryAction() async {
    final snapshot = _snapshot;
    if (snapshot == null || _isHandlingAction) {
      return;
    }

    if (snapshot.requiredPermissionsReady) {
      if (mounted) {
        context.go(AppRoute.home.path);
      }
      return;
    }

    final service = ref.read(devicePermissionsProvider);
    final nextStep = _firstPendingRequired(snapshot);
    if (nextStep == null) {
      return;
    }

    setState(() {
      _isHandlingAction = true;
      _activeStep = nextStep;
      _expandedKind = nextStep;
    });

    switch (nextStep) {
      case PermissionKind.notifications:
        await service.requestNotifications();
      case PermissionKind.usageAccess:
        _showSettingsHint('Activa Acceso de uso para Focus y vuelve a la app.');
        await service.openUsageAccessSettings();
      case PermissionKind.overlay:
        _showSettingsHint('Permite que Focus se muestre sobre otras apps.');
        await service.openOverlaySettings();
      case PermissionKind.files:
      case PermissionKind.accessibility:
        break;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _refreshPermissions();

    if (mounted) {
      setState(() => _isHandlingAction = false);
    }
  }

  void _showSettingsHint(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  PermissionKind? _firstPendingRequired(PermissionSnapshot snapshot) {
    if (!snapshot.notificationsAllowed) {
      return PermissionKind.notifications;
    }
    if (!snapshot.usageAccessAllowed) {
      return PermissionKind.usageAccess;
    }
    if (!snapshot.overlayAllowed) {
      return PermissionKind.overlay;
    }
    return null;
  }

  bool _isPending(PermissionSnapshot snapshot, PermissionKind kind) {
    return switch (kind) {
      PermissionKind.notifications => !snapshot.notificationsAllowed,
      PermissionKind.usageAccess => !snapshot.usageAccessAllowed,
      PermissionKind.overlay => !snapshot.overlayAllowed,
      PermissionKind.files => false,
      PermissionKind.accessibility => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final items = _permissionItems(snapshot);
    final isReady = snapshot?.requiredPermissionsReady ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 34,
                ),
                child: Column(
                  children: [
                    _TopBar(onBack: () => context.go(AppRoute.auth.path)),
                    const SizedBox(height: 18),
                    const _Header(),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: _isRefreshing && snapshot == null
                          ? const _PermissionSkeleton()
                          : Column(
                              key: ValueKey(snapshot),
                              children: [
                                for (final item in items) ...[
                                  _PermissionTile(
                                    item: item,
                                    isExpanded: _expandedKind == item.kind,
                                    isActiveStep:
                                        _activeStep == item.kind &&
                                        !item.isReady,
                                    onTap: () {
                                      setState(() {
                                        _expandedKind =
                                            _expandedKind == item.kind
                                            ? null
                                            : item.kind;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    _ReadinessPanel(isReady: isReady),
                    const SizedBox(height: 20),
                    const SizedBox(height: 24),
                    _PrimaryButton(
                      label: _primaryLabel(snapshot),
                      isLoading:
                          _isHandlingAction ||
                          (_isRefreshing && snapshot != null),
                      isReady: isReady,
                      onPressed: _handlePrimaryAction,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Puedes cambiar estos permisos desde Ajustes cuando quieras.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8FA9C4),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _primaryLabel(PermissionSnapshot? snapshot) {
    if (snapshot == null) {
      return 'Revisando permisos';
    }
    if (snapshot.requiredPermissionsReady) {
      return 'Continuar';
    }

    return switch (_firstPendingRequired(snapshot)) {
      PermissionKind.notifications => 'Permitir notificaciones',
      PermissionKind.usageAccess => 'Activar acceso de uso',
      PermissionKind.overlay => 'Activar ventana de enfoque',
      _ => 'Configurar permisos',
    };
  }

  List<_PermissionItem> _permissionItems(PermissionSnapshot? snapshot) {
    return [
      _PermissionItem(
        kind: PermissionKind.notifications,
        title: 'Notificaciones',
        description:
            'Focus te avisa cuando termina una sesion o cuando toca volver al estudio.',
        icon: Icons.notifications_active_outlined,
        isReady: snapshot?.notificationsAllowed ?? false,
        isRequired: true,
        actionHint: 'Se pedira con una ventana nativa de Android.',
      ),
      _PermissionItem(
        kind: PermissionKind.usageAccess,
        title: 'Acceso de uso',
        description:
            'Nos permite saber si abriste una app distractora durante tu sesion.',
        icon: Icons.phone_android_outlined,
        isReady: snapshot?.usageAccessAllowed ?? false,
        isRequired: true,
        actionHint: 'Android lo activa desde Ajustes, no desde un popup.',
      ),
      _PermissionItem(
        kind: PermissionKind.overlay,
        title: 'Mostrar sobre otras apps',
        description:
            'Sirve para mostrar tu sesion de aprendizaje encima de la distraccion.',
        icon: Icons.layers_outlined,
        isReady: snapshot?.overlayAllowed ?? false,
        isRequired: true,
        actionHint: 'Te llevaremos a la pantalla exacta del sistema.',
      ),
      const _PermissionItem(
        kind: PermissionKind.files,
        title: 'Acceso a archivos',
        description:
            'Al subir apuntes, elegiras un archivo y Focus solo leera ese material.',
        icon: Icons.folder_open_outlined,
        isReady: true,
        isRequired: false,
        actionHint: 'No necesitamos acceso general a tus archivos.',
      ),
      const _PermissionItem(
        kind: PermissionKind.accessibility,
        title: 'Accesibilidad',
        description:
            'Queda reservado para bloqueos avanzados si el modo enfoque lo necesita.',
        icon: Icons.accessibility_new_outlined,
        isReady: false,
        isRequired: false,
        actionHint: 'Opcional por ahora para mantener el flujo simple.',
      ),
    ];
  }
}

enum PermissionKind {
  notifications,
  usageAccess,
  overlay,
  files,
  accessibility,
}

class _PermissionItem {
  const _PermissionItem({
    required this.kind,
    required this.title,
    required this.description,
    required this.icon,
    required this.isReady,
    required this.isRequired,
    required this.actionHint,
  });

  final PermissionKind kind;
  final String title;
  final String description;
  final IconData icon;
  final bool isReady;
  final bool isRequired;
  final String actionHint;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: const Color(0xFFE7F3FF),
          tooltip: 'Volver',
        ),
        const Expanded(
          child: Text(
            'Configuracion',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2DD4BF),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF14395F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E5A7B)),
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF2DD4BF),
            size: 31,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Configura tu modo de enfoque',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFFF1F8FF),
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Focus necesita algunos accesos para bloquear distracciones y convertir el tiempo bloqueado en aprendizaje.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFB9CBE1),
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.isExpanded,
    required this.isActiveStep,
    required this.onTap,
  });

  final _PermissionItem item;
  final bool isExpanded;
  final bool isActiveStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = item.isReady
        ? const Color(0xFF28D7BE)
        : isActiveStep
        ? const Color(0xFF67E8F9)
        : const Color(0xFF174D75);
    final status = item.isReady
        ? 'Activo'
        : item.isRequired
        ? 'Pendiente'
        : 'Opcional';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: item.isRequired
            ? const Color(0xFF103456)
            : const Color(0xFF0D2B49),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withValues(alpha: isActiveStep ? 0.9 : 0.5),
        ),
        boxShadow: [
          if (isActiveStep)
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Column(
              children: [
                Row(
                  children: [
                    _TileIcon(icon: item.icon, isReady: item.isReady),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFFEAF6FF),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _StatusPill(label: status, isReady: item.isReady),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFFB9CBE1),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12, left: 47),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFFB9CBE1),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item.isRequired
                                  ? Icons.info_outline_rounded
                                  : Icons.lock_outline_rounded,
                              color: const Color(0xFF2DD4BF),
                              size: 16,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                item.actionHint,
                                style: const TextStyle(
                                  color: Color(0xFF89DCD2),
                                  fontSize: 12,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon, required this.isReady});

  final IconData icon;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF092845),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isReady ? Icons.check_rounded : icon,
        color: const Color(0xFF2DD4BF),
        size: 20,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.isReady});

  final String label;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isReady
            ? const Color(0xFF134E4A)
            : const Color(0xFF08233D).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isReady ? const Color(0xFF2DD4BF) : const Color(0xFF255E83),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isReady ? const Color(0xFF99F6E4) : const Color(0xFFB9CBE1),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFF0F3B3F) : const Color(0xFF082641),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReady ? const Color(0xFF2DD4BF) : const Color(0xFF1E5A7B),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.verified_rounded : Icons.auto_awesome_outlined,
            color: const Color(0xFF2DD4BF),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isReady
                  ? 'Todo listo. Focus puede guiar tu sesion de aprendizaje.'
                  : 'Iremos paso a paso. Solo pedimos lo necesario para que el modo enfoque funcione.',
              style: const TextStyle(
                color: Color(0xFFDFF7FF),
                height: 1.3,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.isReady,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final bool isReady;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(isReady ? Icons.arrow_forward_rounded : Icons.tune_rounded),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF27C7B8),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1F6A75),
          disabledForegroundColor: const Color(0xFFD4F6F1),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _PermissionSkeleton extends StatelessWidget {
  const _PermissionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < 4; index++) ...[
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF103456),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF174D75)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
