import 'package:flutter/material.dart';

class MyProfilePage extends StatelessWidget {
  final String name;
  final String email;
  final Future<void> Function(String name, String email) onSave;

  const MyProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.onSave,
  });

  Future<void> _editProfile(BuildContext context) async {
    final nameController = TextEditingController(text: name);
    try {
      final updatedName = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updatedName = nameController.text.trim();
                if (updatedName.isEmpty) return;
                Navigator.pop(dialogContext, updatedName);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (updatedName != null) {
        await onSave(updatedName, email);
      }
    } finally {
      nameController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isEmpty ? 'User' : name.trim();
    final initial = displayName.substring(0, 1).toUpperCase();

    return Container(
      color: const Color(0xFF020B12),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Profile', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  color: const Color(0xFF0D1F2D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.greenAccent,
                              foregroundColor: Colors.black,
                              child: Text(initial, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _profileField('Full name', displayName),
                        const SizedBox(height: 16),
                        _profileField('Login email', email.isEmpty ? 'Not available' : email),
                        const SizedBox(height: 20),
                        const Text('Your password is never stored in the profile.', style: TextStyle(color: Colors.white60)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _editProfile(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 4),
        SelectableText(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}