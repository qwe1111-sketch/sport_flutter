import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCodeSent = false;
  Timer? _timer;
  int _countdown = 60;

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (!mounted) return;
    setState(() {
      _isCodeSent = true;
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() {}); // Rebuild to enable the resend button.
      }
    });
  }

  void _sendForgotPasswordCode() {
    if (_formKey.currentState?.validate() == true) {
      _startCountdown();
      context.read<AuthBloc>().add(ForgotPasswordSendCodeEvent(
            _usernameController.text,
            _emailController.text,
          ));
    }
  }

  void _resetForgottenPassword() {
    if (_formKey.currentState?.validate() == true) {
      context.read<AuthBloc>().add(ForgotPasswordResetEvent(
            _usernameController.text,
            _emailController.text,
            _codeController.text,
            _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordCodeSent) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.codeSent)));
          } else if (state is ForgotPasswordSuccess) {
            Navigator.of(context).pop(true);
          } else if (state is AuthError) {
            if (state.errorType == 'ForgotPasswordSendCodeError') {
              _timer?.cancel();
              setState(() => _isCodeSent = false);
            }
            final message = state.message == 'usernameAndEmailMismatch'
                ? l10n.usernameAndEmailMismatch
                : state.message;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.resetYourPassword)),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: l10n.username),
                      validator: (value) => value!.isEmpty ? l10n.enterUsername : null,
                      enabled: !_isCodeSent,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: l10n.email),
                      validator: (value) => (value == null || !value.contains('@')) ? l10n.enterValidEmail : null,
                      enabled: !_isCodeSent,
                    ),
                    if (!_isCodeSent)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: ElevatedButton(
                          onPressed: _sendForgotPasswordCode,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: Text(l10n.sendVerificationCode),
                        ),
                      ),
                    if (_isCodeSent) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: l10n.verificationCode,
                          suffixIcon: TextButton(
                            onPressed: _countdown > 0 ? null : _sendForgotPasswordCode,
                            child: Text(
                              _countdown > 0 ? '$_countdown s' : l10n.sendVerificationCode,
                            ),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? l10n.enterVerificationCode : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: l10n.newPassword),
                        obscureText: true,
                        validator: (value) => (value == null || value.length < 6) ? l10n.passwordTooShort : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(labelText: l10n.confirmNewPassword),
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => value != _passwordController.text ? l10n.passwordsDoNotMatch : null,
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading ? null : _resetForgottenPassword,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(l10n.confirmReset),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
