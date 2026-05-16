import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/providers/auth_provider.dart';
import 'package:wh3re/presentation/widgets/auth_scaffold.dart';
import 'package:wh3re/presentation/widgets/auth_text_field.dart';
import 'package:wh3re/presentation/widgets/wh3re_primary_button.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).clearError();
    await ref.read(authControllerProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    state.whenOrNull(
      data: (_) => setState(() => _emailSent = true),
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return AuthScaffold(
      title: 'Mot de passe oublié',
      subtitle: _emailSent
          ? 'Consultez votre boîte mail pour réinitialiser votre mot de passe.'
          : 'Entrez votre email — nous vous enverrons un lien de réinitialisation.',
      showLogo: false,
      child: _emailSent ? _buildSuccess() : _buildForm(isLoading),
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text(
          'Retour à la connexion',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'vous@exemple.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            prefixIcon: Icons.mail_outline_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Wh3rePrimaryButton(
            label: 'Envoyer le lien',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(AppColors.radiusCard),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Email envoyé !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
