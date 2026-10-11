import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LanguagePage extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onSelect;

  const LanguagePage({
    super.key,
    required this.selectedLanguage,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const languages = [
      ('en', 'English'),
      ('ta', 'தமிழ்'),
      ('hi', 'हिन्दी'),
      ('te', 'తెలుగు'),
    ];

    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Language & Preferences', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 18),
              ...languages.map((language) {
                final isSelected = selectedLanguage == language.$1;
                return Card(
                  color: AppColors.cardDark,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorderDark,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    title: Text(language.$2, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    trailing: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                    onTap: () => onSelect(language.$1),
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'Sidebar and navigation labels adapt to your chosen language. Scientific nomenclature, PDB IDs, and AutoDock Vina calculations remain in standard English.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}