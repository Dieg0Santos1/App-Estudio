import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router.dart';
import '../data/auth_repository.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _badgeController;

  var _isSignUp = false;
  var _isLoading = false;
  var _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..value = 1;
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B38),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BrandHeader(
                    isSignUp: _isSignUp,
                    badgeScale: _badgeController,
                  ),
                  const SizedBox(height: 24),
                  _AuthCard(
                    isSignUp: _isSignUp,
                    isLoading: _isLoading,
                    obscurePassword: _obscurePassword,
                    errorMessage: _errorMessage,
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onForgotPassword: _handleForgotPassword,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 24),
                  _ModeToggle(
                    isSignUp: _isSignUp,
                    onPressed: _toggleMode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
    _badgeController.forward(from: 0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      if (_isSignUp) {
        await repository.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await repository.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      context.go(AppRoute.permissions.path);
    } on AuthException catch (error) {
      _setError(error.message);
    } on StateError {
      _setError('Supabase aun no esta configurado en este entorno.');
    } catch (_) {
      _setError('No pudimos completar la accion. Intentalo otra vez.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _setError('Escribe tu correo para enviarte el enlace de recuperacion.');
      return;
    }

    try {
      await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un enlace de recuperacion.')),
      );
    } on StateError {
      _setError('Supabase aun no esta configurado en este entorno.');
    } catch (_) {
      _setError('No pudimos enviar el enlace de recuperacion.');
    }
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }

    setState(() => _errorMessage = message);
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.isSignUp,
    required this.badgeScale,
  });

  final bool isSignUp;
  final Animation<double> badgeScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 1, end: 0.94), weight: 20),
            TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.06), weight: 45),
            TweenSequenceItem(tween: Tween(begin: 1.06, end: 1), weight: 35),
          ]).animate(
            CurvedAnimation(parent: badgeScale, curve: Curves.easeOutCubic),
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0E3B50),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C7B8).withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF5EEAD4),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Focus',
              style: TextStyle(
                color: Color(0xFFEFF6FF),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF143A52),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF22C7B8).withValues(alpha: 0.42)),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Color(0xFF5EEAD4),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Text(
            isSignUp ? 'Crea tu espacio de estudio inteligente.' : 'Tu sesion de enfoque empieza aqui.',
            key: ValueKey(isSignUp),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB7C6D8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.isSignUp,
    required this.isLoading,
    required this.obscurePassword,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSubmit,
    this.errorMessage,
  });

  final bool isSignUp;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B2B4A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1B4A68)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF020B18).withValues(alpha: 0.34),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          children: [
            _GoogleButton(enabled: false),
            const SizedBox(height: 18),
            const _DividerLabel(),
            const SizedBox(height: 18),
            if (errorMessage != null) ...[
              _InlineError(message: errorMessage!),
              const SizedBox(height: 14),
            ],
            Form(
              key: formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 620),
                reverseDuration: const Duration(milliseconds: 460),
                switchInCurve: Curves.easeOutQuart,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final childKey = child.key as ValueKey<String>?;
                  final incomingSignUp = childKey?.value == 'signup-form';
                  final direction = incomingSignUp ? 1.0 : -1.0;
                  final offset = Tween<Offset>(
                    begin: Offset(0.22 * direction, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: isSignUp
                    ? _SignupForm(
                        key: const ValueKey('signup-form'),
                        isLoading: isLoading,
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        obscurePassword: obscurePassword,
                        onTogglePassword: onTogglePassword,
                        onSubmit: onSubmit,
                      )
                    : _LoginForm(
                        key: const ValueKey('login-form'),
                        isLoading: isLoading,
                        emailController: emailController,
                        passwordController: passwordController,
                        obscurePassword: obscurePassword,
                        onTogglePassword: onTogglePassword,
                        onForgotPassword: onForgotPassword,
                        onSubmit: onSubmit,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSubmit,
    super.key,
  });

  final bool isLoading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        _AnimatedFormItem(
          index: 0,
          child: _FocusTextField(
            controller: emailController,
            label: 'Correo electronico',
            hintText: 'estudiante@ejemplo.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
        ),
        const SizedBox(height: 14),
        _AnimatedFormItem(
          index: 1,
          child: _FocusTextField(
            controller: passwordController,
            label: 'Contrasena',
            hintText: 'Minimo 6 caracteres',
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            validator: _validatePassword,
            trailing: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9FB3C8),
              ),
              tooltip: obscurePassword ? 'Mostrar contrasena' : 'Ocultar contrasena',
            ),
            labelAction: TextButton(
              onPressed: onForgotPassword,
              child: const Text(
                'Olvide mi contrasena',
                style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _AnimatedFormItem(
          index: 2,
          child: _PrimaryAuthButton(
            label: 'Iniciar sesion',
            icon: Icons.login_rounded,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm({
    required this.isLoading,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    super.key,
  });

  final bool isLoading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        _AnimatedFormItem(
          index: 0,
          direction: -1,
          child: _FocusTextField(
            controller: nameController,
            label: 'Nombre',
            hintText: 'Como quieres que te llamemos',
            icon: Icons.person_outline_rounded,
            validator: _validateName,
          ),
        ),
        const SizedBox(height: 14),
        _AnimatedFormItem(
          index: 1,
          direction: -1,
          child: _FocusTextField(
            controller: emailController,
            label: 'Correo electronico',
            hintText: 'estudiante@ejemplo.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
        ),
        const SizedBox(height: 14),
        _AnimatedFormItem(
          index: 2,
          direction: -1,
          child: _FocusTextField(
            controller: passwordController,
            label: 'Contrasena',
            hintText: 'Minimo 6 caracteres',
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            validator: _validatePassword,
            trailing: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9FB3C8),
              ),
              tooltip: obscurePassword ? 'Mostrar contrasena' : 'Ocultar contrasena',
            ),
          ),
        ),
        const SizedBox(height: 18),
        _AnimatedFormItem(
          index: 3,
          direction: -1,
          child: _PrimaryAuthButton(
            label: 'Crear cuenta',
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

class _AnimatedFormItem extends StatelessWidget {
  const _AnimatedFormItem({
    required this.index,
    required this.child,
    this.direction = 1,
  });

  final int index;
  final double direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + index * 110),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 26 * direction, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _FocusTextField extends StatelessWidget {
  const _FocusTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.labelAction,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;
  final Widget? labelAction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFD5E3F3),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?labelAction,
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          enabled: true,
          style: const TextStyle(
            color: Color(0xFFEFF6FF),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF6D8298)),
            prefixIcon: Icon(icon, color: const Color(0xFFB7C6D8), size: 21),
            suffixIcon: trailing,
            filled: true,
            fillColor: const Color(0xFF061B38),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: _inputBorder(const Color(0xFF173E5B)),
            enabledBorder: _inputBorder(const Color(0xFF173E5B)),
            focusedBorder: _inputBorder(const Color(0xFF2DD4BF)),
            errorBorder: _inputBorder(const Color(0xFFF87171)),
            focusedErrorBorder: _inputBorder(const Color(0xFFF87171)),
            errorStyle: const TextStyle(color: Color(0xFFFFB4B4), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF22C7B8),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2C6C7A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? () {} : null,
        icon: const Text(
          'G',
          style: TextStyle(
            color: Color(0xFF2DD4BF),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        label: Text(enabled ? 'Continuar con Google' : 'Google pronto'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEFF6FF),
          disabledForegroundColor: const Color(0xFF6C8298),
          backgroundColor: const Color(0xFF143A52),
          disabledBackgroundColor: const Color(0xFF102B42),
          side: const BorderSide(color: Color(0xFF1B4A68)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF1B4A68))),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'O usa tu correo',
                style: const TextStyle(
                  color: Color(0xFF91A8BE),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF1B4A68))),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A1D2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.45)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFFFD2D2),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isSignUp,
    required this.onPressed,
  });

  final bool isSignUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Wrap(
        key: ValueKey(isSignUp),
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            isSignUp ? 'Ya tienes cuenta?' : 'Aun no tienes cuenta?',
            style: const TextStyle(
              color: Color(0xFFB7C6D8),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              isSignUp ? 'Iniciar sesion' : 'Crear cuenta',
              style: const TextStyle(
                color: Color(0xFF2DD4BF),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _validateName(String? value) {
  if (value == null || value.trim().length < 2) {
    return 'Escribe tu nombre.';
  }

  return null;
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Escribe un correo valido.';
  }

  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Usa al menos 6 caracteres.';
  }

  return null;
}
