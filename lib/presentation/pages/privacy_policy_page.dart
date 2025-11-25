import 'package:flutter/material.dart';
import 'package:sport_flutter/l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          l10n.privacyPolicyContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
