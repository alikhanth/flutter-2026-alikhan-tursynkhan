import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';

class TabProfile extends StatefulWidget {
  final Profile profile;
  final List<Item> items;
  final ThemeMode themeMode;
  final Function(Profile) onProfileChanged;
  final Function(ThemeMode) onThemeChanged;

  const TabProfile({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeChanged,
  });

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _groupCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _groupCtrl = TextEditingController(text: widget.profile.group);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() == true) {
      widget.onProfileChanged(
        Profile(name: _nameCtrl.text, group: _groupCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int listsCount =
        widget.items.where((e) => e.contains(widget.profile.name)).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _groupCtrl,
              decoration:
              const InputDecoration(labelText: 'Group (e.g. CS-101)'),
              onFieldSubmitted: (_) => _save(),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return null;
                }
                if (!RegExp(r'^[A-Z]+-\d+$').hasMatch(val)) {
                  return 'Must match XXX-000';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'You are on $listsCount lists',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: ThemeMode.values
                  .map(
                    (mode) => ChoiceChip(
                  label: Text(mode.name),
                  selected: widget.themeMode == mode,
                  onSelected: (v) {
                    if (v) {
                      widget.onThemeChanged(mode);
                    }
                  },
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}