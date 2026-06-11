import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/models/study_enums.dart';
import '../../../shared/presentation/focus_bottom_nav.dart';

class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key});

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  final _topicController = TextEditingController(
    text: 'Programacion Orientada a Objetos',
  );

  var _stepIndex = 0;
  var _selectedMaterialId = _mockMaterials.first.id;
  var _selectedMethod = StudyMethod.visual;
  var _selectedDuration = 30;
  var _selectedMode = StudyMode.normal;
  final Set<String> _blockedAppIds = {'instagram', 'youtube', 'tiktok'};

  static const _stepLabels = ['Material', 'Aprendizaje', 'Enfoque'];
  static const _durations = [15, 30, 45, 60];

  @override
  void dispose() {
    _topicController.removeListener(_onTopicChanged);
    _topicController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _topicController.addListener(_onTopicChanged);
  }

  void _onTopicChanged() {
    setState(() {});
  }

  void _nextStep() {
    if (_stepIndex < 2) {
      setState(() => _stepIndex += 1);
      return;
    }

    context.go(AppRoute.focusMode.path);
  }

  void _previousStep() {
    if (_stepIndex == 0) {
      context.go(AppRoute.home.path);
      return;
    }

    setState(() => _stepIndex -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMaterial = _mockMaterials.firstWhere(
      (material) => material.id == _selectedMaterialId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      bottomNavigationBar: const FocusBottomNav(
        currentRoute: AppRoute.studySession,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: _previousStep),
            _StepIndicator(currentStep: _stepIndex, labels: _stepLabels),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: _StepBody(
                  key: ValueKey(_stepIndex),
                  stepIndex: _stepIndex,
                  topicController: _topicController,
                  selectedMaterialId: _selectedMaterialId,
                  selectedMethod: _selectedMethod,
                  selectedDuration: _selectedDuration,
                  selectedMode: _selectedMode,
                  blockedAppIds: _blockedAppIds,
                  selectedMaterial: selectedMaterial,
                  onMaterialChanged: (id) =>
                      setState(() => _selectedMaterialId = id),
                  onMethodChanged: (method) =>
                      setState(() => _selectedMethod = method),
                  onDurationChanged: (duration) {
                    setState(() => _selectedDuration = duration);
                  },
                  onModeChanged: (mode) => setState(() => _selectedMode = mode),
                  onToggleApp: (id) {
                    setState(() {
                      if (_blockedAppIds.contains(id)) {
                        _blockedAppIds.remove(id);
                      } else {
                        _blockedAppIds.add(id);
                      }
                    });
                  },
                ),
              ),
            ),
            _ActionBar(
              stepIndex: _stepIndex,
              canContinue: _topicController.text.trim().isNotEmpty,
              onBack: _previousStep,
              onContinue: _nextStep,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFFEAF6FF),
            tooltip: 'Volver',
          ),
          const Expanded(
            child: Text(
              'Nueva sesion',
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
            icon: const Icon(Icons.more_horiz_rounded),
            color: Color(0xFFEAF6FF),
            tooltip: 'Opciones',
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.labels});

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (currentStep) {
              0 => 'Que vas a estudiar?',
              1 => 'Como quieres aprender?',
              _ => 'Que quieres bloquear?',
            },
            style: const TextStyle(
              color: Color(0xFFF1F8FF),
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            switch (currentStep) {
              0 => 'Elige el tema y el material base de la sesion.',
              1 => 'Focus adaptara el contenido segun tu estilo de estudio.',
              _ => 'Revisa el bloqueo y confirma antes de empezar.',
            },
            style: const TextStyle(
              color: Color(0xFFB9CBE1),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var index = 0; index < labels.length; index++) ...[
                Expanded(
                  child: _StepChip(
                    label: labels[index],
                    index: index,
                    isActive: index == currentStep,
                    isDone: index < currentStep,
                  ),
                ),
                if (index != labels.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isDone,
  });

  final String label;
  final int index;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? const Color(0xFF143E5F)
        : const Color(0xFF092641);
    final borderColor = isActive || isDone
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF174D75);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFF2DD4BF) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFFEAF6FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFFEAF6FF)
                      : const Color(0xFFB9CBE1),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.stepIndex,
    required this.topicController,
    required this.selectedMaterialId,
    required this.selectedMethod,
    required this.selectedDuration,
    required this.selectedMode,
    required this.blockedAppIds,
    required this.selectedMaterial,
    required this.onMaterialChanged,
    required this.onMethodChanged,
    required this.onDurationChanged,
    required this.onModeChanged,
    required this.onToggleApp,
    super.key,
  });

  final int stepIndex;
  final TextEditingController topicController;
  final String selectedMaterialId;
  final StudyMethod selectedMethod;
  final int selectedDuration;
  final StudyMode selectedMode;
  final Set<String> blockedAppIds;
  final _SessionMaterial selectedMaterial;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<StudyMethod> onMethodChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<StudyMode> onModeChanged;
  final ValueChanged<String> onToggleApp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      children: [
        switch (stepIndex) {
          0 => _MaterialStep(
            topicController: topicController,
            selectedMaterialId: selectedMaterialId,
            onMaterialChanged: onMaterialChanged,
          ),
          1 => _LearningStep(
            selectedMethod: selectedMethod,
            selectedDuration: selectedDuration,
            selectedMode: selectedMode,
            onMethodChanged: onMethodChanged,
            onDurationChanged: onDurationChanged,
            onModeChanged: onModeChanged,
          ),
          _ => _FocusStep(
            topic: topicController.text.trim(),
            selectedMaterial: selectedMaterial,
            selectedMethod: selectedMethod,
            selectedDuration: selectedDuration,
            selectedMode: selectedMode,
            blockedAppIds: blockedAppIds,
            onToggleApp: onToggleApp,
          ),
        },
      ],
    );
  }
}

class _MaterialStep extends StatelessWidget {
  const _MaterialStep({
    required this.topicController,
    required this.selectedMaterialId,
    required this.onMaterialChanged,
  });

  final TextEditingController topicController;
  final String selectedMaterialId;
  final ValueChanged<String> onMaterialChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          icon: Icons.school_outlined,
          title: 'Tema principal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: topicController,
                style: const TextStyle(
                  color: Color(0xFFF1F8FF),
                  fontWeight: FontWeight.w800,
                ),
                decoration: _inputDecoration(
                  'Ej. Programacion Orientada a Objetos',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Usaremos este tema para preparar resumen, guia y comprobacion.',
                style: TextStyle(
                  color: Color(0xFF91A8C2),
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          icon: Icons.description_outlined,
          title: 'Material de estudio',
          trailing: TextButton.icon(
            onPressed: () => context.go(AppRoute.library.path),
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Agregar'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2DD4BF),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          child: Column(
            children: [
              for (final material in _mockMaterials) ...[
                _MaterialTile(
                  material: material,
                  isSelected: selectedMaterialId == material.id,
                  onTap: () => onMaterialChanged(material.id),
                ),
                if (material != _mockMaterials.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _TipPanel(
          icon: Icons.lock_outline_rounded,
          text:
              'Focus no necesita acceso general a tus archivos. Solo usara el material que elijas.',
        ),
      ],
    );
  }
}

class _LearningStep extends StatelessWidget {
  const _LearningStep({
    required this.selectedMethod,
    required this.selectedDuration,
    required this.selectedMode,
    required this.onMethodChanged,
    required this.onDurationChanged,
    required this.onModeChanged,
  });

  final StudyMethod selectedMethod;
  final int selectedDuration;
  final StudyMode selectedMode;
  final ValueChanged<StudyMethod> onMethodChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<StudyMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          icon: Icons.psychology_alt_outlined,
          title: 'Tipo de estudio',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.48,
            children: [
              for (final option in _methodOptions)
                _StudyMethodCard(
                  option: option,
                  isSelected: selectedMethod == option.method,
                  onTap: () => onMethodChanged(option.method),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          icon: Icons.timer_outlined,
          title: 'Duracion',
          child: Row(
            children: [
              for (final duration in _StudySessionScreenState._durations) ...[
                Expanded(
                  child: _ChoicePill(
                    title: '$duration',
                    subtitle: 'min',
                    isSelected: selectedDuration == duration,
                    onTap: () => onDurationChanged(duration),
                  ),
                ),
                if (duration != _StudySessionScreenState._durations.last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          icon: Icons.fitness_center_outlined,
          title: 'Nivel de reto',
          child: Column(
            children: [
              for (final mode in _modeOptions) ...[
                _ModeTile(
                  option: mode,
                  isSelected: selectedMode == mode.mode,
                  onTap: () => onModeChanged(mode.mode),
                ),
                if (mode != _modeOptions.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusStep extends StatelessWidget {
  const _FocusStep({
    required this.topic,
    required this.selectedMaterial,
    required this.selectedMethod,
    required this.selectedDuration,
    required this.selectedMode,
    required this.blockedAppIds,
    required this.onToggleApp,
  });

  final String topic;
  final _SessionMaterial selectedMaterial;
  final StudyMethod selectedMethod;
  final int selectedDuration;
  final StudyMode selectedMode;
  final Set<String> blockedAppIds;
  final ValueChanged<String> onToggleApp;

  @override
  Widget build(BuildContext context) {
    final method = _methodOptions.firstWhere(
      (option) => option.method == selectedMethod,
    );
    final mode = _modeOptions.firstWhere(
      (option) => option.mode == selectedMode,
    );

    return Column(
      children: [
        _Panel(
          icon: Icons.block_outlined,
          title: 'Apps a bloquear',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige las distracciones que Focus interceptara durante la sesion.',
                style: TextStyle(
                  color: Color(0xFFB9CBE1),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final app in _focusApps)
                    _BlockedAppChip(
                      app: app,
                      isSelected: blockedAppIds.contains(app.id),
                      onTap: () => onToggleApp(app.id),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          icon: Icons.fact_check_outlined,
          title: 'Resumen de la sesion',
          child: Column(
            children: [
              _SummaryRow(
                label: 'Tema',
                value: topic.isEmpty ? 'Sin tema' : topic,
              ),
              _SummaryRow(label: 'Material', value: selectedMaterial.title),
              _SummaryRow(label: 'Tipo de estudio', value: method.title),
              _SummaryRow(label: 'Duracion', value: '$selectedDuration min'),
              _SummaryRow(label: 'Nivel de reto', value: mode.title),
              _SummaryRow(
                label: 'Apps bloqueadas',
                value: '${blockedAppIds.length} apps',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _TipPanel(icon: method.icon, text: method.sessionPreview),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.stepIndex,
    required this.canContinue,
    required this.onBack,
    required this.onContinue,
  });

  final int stepIndex;
  final bool canContinue;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF061B34).withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: Color(0xFF123B5D))),
        ),
        child: Row(
          children: [
            if (stepIndex > 0) ...[
              SizedBox(
                width: 50,
                height: 52,
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEAF6FF),
                    side: const BorderSide(color: Color(0xFF2B6C8C)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: canContinue ? onContinue : null,
                  icon: Icon(
                    stepIndex == 2
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(stepIndex == 2 ? 'Iniciar sesion' : 'Continuar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF27C7B8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1F6A75),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF092845),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2DD4BF), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFF1F8FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: Color(0xFF6F87A4),
      fontWeight: FontWeight.w700,
    ),
    filled: true,
    fillColor: const Color(0xFF082641),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF174D75)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.5),
    ),
  );
}

class _MaterialTile extends StatelessWidget {
  const _MaterialTile({
    required this.material,
    required this.isSelected,
    required this.onTap,
  });

  final _SessionMaterial material;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4054) : const Color(0xFF082641),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF174D75),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
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
                    '${material.subtitle}  ·  ${material.sizeLabel}',
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                key: ValueKey(isSelected),
                color: isSelected
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF6985A2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyMethodCard extends StatelessWidget {
  const _StudyMethodCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _MethodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4054) : const Color(0xFF082641),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF174D75),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(option.icon, color: option.color, size: 23),
            const Spacer(),
            Text(
              option.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFF1F8FF),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.shortDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFB9CBE1),
                fontSize: 11,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 62,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4054) : const Color(0xFF082641),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF174D75),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF99F6E4)
                    : const Color(0xFFEAF6FF),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFB9CBE1),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ModeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4054) : const Color(0xFF082641),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF174D75),
          ),
        ),
        child: Row(
          children: [
            Icon(option.icon, color: option.color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      color: Color(0xFFF1F8FF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFB9CBE1),
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF2DD4BF)
                  : const Color(0xFF6985A2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedAppChip extends StatelessWidget {
  const _BlockedAppChip({
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  final _FocusApp app;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4054) : const Color(0xFF082641),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2DD4BF)
                : const Color(0xFF174D75),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(app.icon, color: app.color, size: 18),
            const SizedBox(width: 7),
            Text(
              app.name,
              style: const TextStyle(
                color: Color(0xFFEAF6FF),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_rounded,
                color: Color(0xFF2DD4BF),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF91A8C2),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFF1F8FF),
                fontSize: 12,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipPanel extends StatelessWidget {
  const _TipPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF082641),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E5A7B)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF67E8F9), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFDFF7FF),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionMaterial {
  const _SessionMaterial({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sizeLabel,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final String sizeLabel;
  final IconData icon;
  final Color color;
}

class _MethodOption {
  const _MethodOption({
    required this.method,
    required this.title,
    required this.shortDescription,
    required this.sessionPreview,
    required this.icon,
    required this.color,
  });

  final StudyMethod method;
  final String title;
  final String shortDescription;
  final String sessionPreview;
  final IconData icon;
  final Color color;
}

class _ModeOption {
  const _ModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final StudyMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _FocusApp {
  const _FocusApp({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

const _mockMaterials = [
  _SessionMaterial(
    id: 'poo-summary',
    title: 'POO_Resumen_Final.pdf',
    subtitle: 'Procesado por IA',
    sizeLabel: '2.4 MB',
    icon: Icons.picture_as_pdf_rounded,
    color: Color(0xFFE85D75),
  ),
  _SessionMaterial(
    id: 'diapos-poo',
    title: 'Diapositivas_POO.pptx',
    subtitle: 'Listo para estudiar',
    sizeLabel: '5.1 MB',
    icon: Icons.slideshow_rounded,
    color: Color(0xFFFF9F6E),
  ),
  _SessionMaterial(
    id: 'notes-s3',
    title: 'Apuntes_Clases_S3.md',
    subtitle: 'Notas importadas',
    sizeLabel: '1.2 MB',
    icon: Icons.article_rounded,
    color: Color(0xFFE7C948),
  ),
];

const _methodOptions = [
  _MethodOption(
    method: StudyMethod.visual,
    title: 'Visual',
    shortDescription: 'Mapas, tarjetas e ideas clave.',
    sessionPreview:
        'Veras una ruta visual del tema y Focus comprobara tu comprension con relaciones de conceptos.',
    icon: Icons.visibility_outlined,
    color: Color(0xFF67E8F9),
  ),
  _MethodOption(
    method: StudyMethod.audio,
    title: 'Auditivo',
    shortDescription: 'Explicacion narrada y repaso oral.',
    sessionPreview:
        'Focus preparara una explicacion estilo audio y preguntas de recuerdo para responder despues.',
    icon: Icons.headphones_rounded,
    color: Color(0xFFA78BFA),
  ),
  _MethodOption(
    method: StudyMethod.writing,
    title: 'Escritura',
    shortDescription: 'Explica con tus palabras.',
    sessionPreview:
        'La sesion te pedira redactar respuestas cortas y evaluara si realmente entendiste.',
    icon: Icons.edit_note_rounded,
    color: Color(0xFFFBBF24),
  ),
  _MethodOption(
    method: StudyMethod.mixed,
    title: 'Mixto',
    shortDescription: 'Combina lectura, guia y practica.',
    sessionPreview:
        'Focus mezclara resumen, guia activa y preguntas variadas para una sesion completa.',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF34D399),
  ),
];

const _modeOptions = [
  _ModeOption(
    mode: StudyMode.light,
    title: 'Suave',
    description: 'Ideal para repasar sin presion.',
    icon: Icons.spa_outlined,
    color: Color(0xFF8BE9D8),
  ),
  _ModeOption(
    mode: StudyMode.normal,
    title: 'Intermedio',
    description: 'Buen balance entre avance y comprobacion.',
    icon: Icons.bolt_rounded,
    color: Color(0xFF67E8F9),
  ),
  _ModeOption(
    mode: StudyMode.strict,
    title: 'Exigente',
    description: 'Mas enfoque, mas bloqueo y mayor reto.',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFBBF24),
  ),
];

const _focusApps = [
  _FocusApp(
    id: 'instagram',
    name: 'Instagram',
    icon: Icons.photo_camera_outlined,
    color: Color(0xFFF472B6),
  ),
  _FocusApp(
    id: 'tiktok',
    name: 'TikTok',
    icon: Icons.music_note_rounded,
    color: Color(0xFF67E8F9),
  ),
  _FocusApp(
    id: 'youtube',
    name: 'YouTube',
    icon: Icons.play_circle_outline_rounded,
    color: Color(0xFFF87171),
  ),
  _FocusApp(
    id: 'browser',
    name: 'Chrome',
    icon: Icons.public_rounded,
    color: Color(0xFF60A5FA),
  ),
  _FocusApp(
    id: 'games',
    name: 'Juegos',
    icon: Icons.sports_esports_outlined,
    color: Color(0xFF34D399),
  ),
];
