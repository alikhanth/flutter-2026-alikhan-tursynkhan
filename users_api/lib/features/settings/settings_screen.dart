import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;

    final cities = {
      for (final u in users) u.address.city,
      ?settings.city,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Saved immediately to SharedPreferences'),
            value: settings.dark,
            onChanged: (v) async => settings.setDark(v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: settings.city,
            decoration: const InputDecoration(
              labelText: 'Filter by city',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All cities'),
              ),
              for (final city in cities)
                DropdownMenuItem<String?>(value: city, child: Text(city)),
            ],
            onChanged: (value) async => settings.setCity(value),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await context.read<AuthModel>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
