import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  final String theme;
  final bool animationsEnabled;
  final bool notificationsEnabled;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<bool> onAnimationsChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final Future<void> Function() onClearHistory;
  final Future<void> Function() onClearSavedResults;

  const SettingsPage({
    super.key,
    required this.theme,
    required this.animationsEnabled,
    required this.notificationsEnabled,
    required this.onThemeChanged,
    required this.onAnimationsChanged,
    required this.onNotificationsChanged,
    required this.onClearHistory,
    required this.onClearSavedResults,
  });

  Future<void> _confirmClear(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final surfaceColor = currentTheme.cardColor;

    return Container(
      color: currentTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              Card(
                color: surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: AppTheme.themeOptions.any((opt) => opt['key'] == theme) ? theme : AppTheme.dark,
                    decoration: const InputDecoration(labelText: 'Theme preference', border: InputBorder.none),
                    items: AppTheme.themeOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['key']!,
                        child: Text(opt['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onThemeChanged(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: surfaceColor,
                child: SwitchListTile.adaptive(
                  title: const Text('Animations'),
                  subtitle: const Text('Animate page and navigation changes'),
                  value: animationsEnabled,
                  onChanged: onAnimationsChanged,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: surfaceColor,
                child: SwitchListTile.adaptive(
                  title: const Text('Notifications'),
                  subtitle: const Text('Show in-app save and activity confirmations'),
                  value: notificationsEnabled,
                  onChanged: onNotificationsChanged,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: surfaceColor,
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Clear history'),
                  subtitle: const Text('Delete this account’s docking history'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmClear(
                    context,
                    title: 'Clear docking history?',
                    message: 'This removes history for the currently logged-in account.',
                    onConfirm: onClearHistory,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: surfaceColor,
                child: ListTile(
                  leading: const Icon(Icons.bookmark_remove_rounded, color: Colors.orangeAccent),
                  title: const Text('Clear saved results'),
                  subtitle: const Text('Delete this account’s saved docking results'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _confirmClear(
                    context,
                    title: 'Clear saved results?',
                    message: 'This removes saved results for the currently logged-in account.',
                    onConfirm: onClearSavedResults,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: surfaceColor,
                child: ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: currentTheme.colorScheme.primary),
                  title: const Text('About DockHub Bio'),
                  subtitle: const Text('Molecular docking workspace'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'DockHub Bio',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Molecular docking workspace using RCSB PDB, PubChem, and AutoDock Vina.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}