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
  bool _isPasswordVisible = false;
  bool _isAgreementChecked = false;
  bool _isCodeSent = false;
  Timer? _timer;
  int _countdown = 60;

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
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
    if (_formKey.currentState!.validate()) {
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.registrationSuccessful), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(); // Go back to login page
          }
          if (state is AuthError) {
            if (state.errorType == 'SendCodeError') {
              _timer?.cancel();
              setState(() => _isCodeSent = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is AuthCodeSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.codeSent), backgroundColor: Colors.blue),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: l10n.username),
                    validator: (value) => value!.isEmpty ? l10n.enterUsername : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                    validator: (value) => value!.isEmpty || !value.contains('@') ? l10n.enterValidEmail : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) => value!.length < 6 ? l10n.passwordTooShort : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: l10n.verificationCode),
                          validator: (value) => value!.isEmpty ? l10n.enterVerificationCode : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isCodeSent ? null : _sendVerificationCode,
                        child: Text(_isCodeSent ? '$_countdown s' : l10n.sendVerificationCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isAgreementChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAgreementChecked = value ?? false;
                          });
                        },
                      ),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: <TextSpan>[
                              TextSpan(text: l10n.agreement),
                              TextSpan(
                                text: l10n.privacyPolicy,
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const PrivacyPolicyPage(),
                                    ));
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isAgreementChecked ? _register : null,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: state is AuthLoading ? const CircularProgressIndicator() : Text(l10n.register),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
