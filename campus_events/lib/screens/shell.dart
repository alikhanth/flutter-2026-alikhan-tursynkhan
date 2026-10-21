import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../routes.dart';
import 'tab_favourites.dart';
import 'tab_list.dart';
import 'tab_profile.dart';

class ShellScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const ShellScreen(
      {super.key, required this.themeMode, required this.onThemeChanged});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;
  List<Item> _items = generateSeedItems();
  Profile _profile = const Profile.empty();

  void _switchTab(int index) => setState(() => _currentIndex = index);
  void _updateProfile(Profile p) => setState(() => _profile = p);

  void _toggleFavourite(Item item) {
    setState(() => _items = _items
        .map((e) => e.id == item.id ? e.copyWith(favourite: !e.favourite) : e)
        .toList());
  }

  void _register(Item item) {
    setState(() {
      _items = _items.map((e) {
        if (e.id == item.id && !e.isFull && !e.contains(_profile.name)) {
          return e.copyWith(attendees: [...e.attendees, _profile.name]);
        }
        return e;
      }).toList();
    });
  }

  void _unregister(Item item) {
    setState(() {
      _items = _items.map((e) {
        if (e.id == item.id && e.contains(_profile.name)) {
          return e.copyWith(
              attendees:
                  e.attendees.where((name) => name != _profile.name).toList());
        }
        return e;
      }).toList();
    });
  }

  void _addItem(Item item) => setState(() => _items = [..._items, item]);
  void _editItem(Item item) => setState(
      () => _items = _items.map((e) => e.id == item.id ? item : e).toList());
  void _deleteItem(Item item) =>
      setState(() => _items = _items.where((e) => e.id != item.id).toList());
  void _resetData() => setState(() {
        _items = generateSeedItems();
        _profile = const Profile.empty();
      });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TabList(
        items: _items,
        profile: _profile,
        onToggleFavourite: _toggleFavourite,
        onRegister: _register,
        onUnregister: _unregister,
        onAddItem: _addItem,
        onEditItem: _editItem,
        onDeleteItem: _deleteItem,
        onSwitchTab: _switchTab,
      ),
      TabFavourites(
        items: _items.where((e) => e.favourite).toList(),
        profile: _profile,
        onToggleFavourite: _toggleFavourite,
        onRegister: _register,
        onUnregister: _unregister,
        onEditItem: _editItem,
        onDeleteItem: _deleteItem,
        onSwitchTab: _switchTab,
      ),
      TabProfile(
        profile: _profile,
        items: _items,
        themeMode: widget.themeMode,
        onProfileChanged: _updateProfile,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    Widget? fab;
    if (_currentIndex == 0) {
      fab = FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.pushNamed<Item>(context, Routes.form,
              arguments: FormArgs(null));
          if (newItem != null && mounted) _addItem(newItem);
        },
        child: const Icon(Icons.add),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(['Events', 'Favourites', 'Profile'][_currentIndex])),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Campus Events')),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                        title: Text('About'),
                        content: Text('Campus Events App.')));
              },
            ),
            ListTile(
              title: const Text('Reset data'),
              onTap: () {
                Navigator.pop(context);
                showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset data?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset')),
                    ],
                  ),
                ).then((value) {
                  if (value == true && mounted) _resetData();
                });
              },
            ),
          ],
        ),
      ),
      body: tabs[_currentIndex],
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Events'),
          NavigationDestination(
              icon: Icon(Icons.favorite), label: 'Favourites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
