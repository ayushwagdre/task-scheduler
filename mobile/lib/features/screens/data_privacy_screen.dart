import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('What we store', style: AppTextStyles.cta.copyWith(fontSize: 20, letterSpacing: 0)),
          const SizedBox(height: 8),
          Text(
            '- Email (for account)\n'
            '- Tasks you create (title, schedule, timezone)\n'
            '- Completion/streak metadata\n',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text('What we do not collect', style: AppTextStyles.cta.copyWith(fontSize: 20, letterSpacing: 0)),
          const SizedBox(height: 8),
          Text(
            '- Location\n- Contacts\n- Advertising identifiers',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text('Your controls', style: AppTextStyles.cta.copyWith(fontSize: 20, letterSpacing: 0)),
          const SizedBox(height: 8),
          Text(
            'You can sign out anytime. You can also delete your account from the Profile screen, which deletes your server data.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            'Privacy policy',
            style: AppTextStyles.cta.copyWith(fontSize: 20, letterSpacing: 0),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your hosted privacy policy URL and open it from here before publishing to Google Play.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

