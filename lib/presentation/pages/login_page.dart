import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';
import 'package:sport_flutter/presentation/bloc/auth_bloc.dart';
import 'package:sport_flutter/presentation/pages/forgot_password_page.dart';
import 'package:sport_flutter/presentation/pages/home_page.dart';
import 'package:sport_flutter/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _backendError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    setState(() {
      _backendError = null;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginEvent(_usernameController.text, _passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (state is AuthError) {
            setState(() {
              _backendError = l10n.invalidUsernameOrPassword;
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: l10n.username),
                    validator: (value) => value!.isEmpty ? l10n.enterUsername : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? l10n.enterPassword : null,
                  ),
                  const SizedBox(height: 20),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else ...[
                    if (_backendError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(_backendError!, style: const TextStyle(color: Colors.red)),
                      ),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text(l10n.login),
                    ),
                  ],
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<AuthBloc>(context),
                            child: const RegisterPage(),
                          ),
                        ),
                      );
                    },
                    child: Text(l10n.dontHaveAnAccount),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: BlocProvider.of<AuthBloc>(context),
                            child: const ForgotPasswordPage(),
                          ),
                        ),
                      );
                      if (result == true) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.codeSent)));
                      }
                    },
                    child: Text(l10n.forgotPassword),
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
