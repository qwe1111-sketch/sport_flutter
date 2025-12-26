import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/pages/privacy_policy_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  final _invitationCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isAgreementChecked = false;
  bool _isCodeSent = false;
  bool _isInvitationCodeCorrect = false; // New state
  Timer? _timer;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _invitationCodeController.addListener(_checkInvitationCode);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _invitationCodeController.removeListener(_checkInvitationCode);
    _invitationCodeController.dispose();
    super.dispose();
  }

  void _checkInvitationCode() {
    final isCorrect = _invitationCodeController.text == 'ABCDEFG';
    if (isCorrect != _isInvitationCodeCorrect) {
      setState(() {
        _isInvitationCodeCorrect = isCorrect;
      });
    }
  }

  void _startCountdown() {
    if (!mounted) return;
    setState(() {
      _isCodeSent = true;
      _countdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() => _isCodeSent = false);
      }
    });
  }

  void _register() {
    if (_formKey.currentState!.validate() && _isAgreementChecked) {
      context.read<AuthBloc>().add(
            RegisterEvent(
              _usernameController.text,
              _emailController.text,
              _passwordController.text,
              _codeController.text,
            ),
          );
    }
  }

  void _sendVerificationCode() {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isNotEmpty && _emailController.text.contains('@')) {
      _startCountdown();
      context.read<AuthBloc>().add(SendCodeEvent(_emailController.text));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidEmail)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.registrationSuccessful), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          }
          if (state is AuthError) {
            if (state.errorType == 'SendCodeError') {
              _timer?.cancel();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() => _isCodeSent = false);
                }
              });
            }
            
            String message;
            switch (state.message) {
              case 'pleaseRequestVerificationCodeFirst':
                message = l10n.pleaseRequestVerificationCodeFirst;
                break;
              case 'incorrectInvitationCode':
                message = l10n.incorrectInvitationCode;
                break;
              case 'invalidUsernameOrPassword':
                message = l10n.invalidUsernameOrPassword;
                break;
              case 'usernameAndEmailMismatch':
                message = l10n.usernameAndEmailMismatch;
                break;
              case 'invalidVerificationCode':
                message = l10n.invalidVerificationCode;
                break;
              default:
                message = state.message;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: colorScheme.error),
            );
          }
          if (state is AuthCodeSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.codeSent), backgroundColor: colorScheme.primary),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: l10n.username,
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              validator: (value) => value!.isEmpty ? l10n.enterUsername : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              validator: (value) => value!.isEmpty || !value.contains('@') ? l10n.enterValidEmail : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) => value!.length < 6 ? l10n.passwordTooShort : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _codeController,
                                    decoration: InputDecoration(
                                      labelText: l10n.verificationCode,
                                      prefixIcon: const Icon(Icons.verified_user_outlined),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      filled: true,
                                      fillColor: colorScheme.surfaceContainerHighest,
                                    ),
                                    validator: (value) => value!.isEmpty ? l10n.enterVerificationCode : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isCodeSent ? null : _sendVerificationCode,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(_isCodeSent ? '$_countdown s' : l10n.sendVerificationCode),
                                ),
                              ],
                            ),
                             const SizedBox(height: 16),
                            TextFormField(
                              controller: _invitationCodeController,
                              decoration: InputDecoration(
                                labelText: l10n.invitationCode,
                                prefixIcon: const Icon(Icons.code),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != 'ABCDEFG') {
                                  return l10n.incorrectInvitationCode;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _isAgreementChecked,
                                  onChanged: (bool? value) => setState(() => _isAgreementChecked = value ?? false),
                                ),
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      style: textTheme.bodySmall,
                                      children: <TextSpan>[
                                        TextSpan(text: l10n.agreement, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                        TextSpan(
                                          text: l10n.privacyPolicy,
                                          style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isAgreementChecked && _isInvitationCodeCorrect ? _register : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: state is AuthLoading ? const CircularProgressIndicator(color: Colors.white) : Text(l10n.register.toUpperCase()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
