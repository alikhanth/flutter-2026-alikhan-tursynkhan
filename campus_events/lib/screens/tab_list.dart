import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_grid_or_list.dart';

class TabList extends StatefulWidget {
  final List<Item> items;
  final Profile profile;
  final Function(Item) onToggleFavourite;
  final Function(Item) onRegister;
  final Function(Item) onUnregister;
  final Function(Item) onAddItem;
  final Function(Item) onEditItem;
  final Function(Item) onDeleteItem;
  final Function(int) onSwitchTab;

  const TabList({
    super.key,
    required this.items,
    required this.profile,
    required this.onToggleFavourite,
    required this.onRegister,
    required this.onUnregister,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onSwitchTab,
  });

  @override
  State<TabList> createState() => _TabListState();
}

class _TabListState extends State<TabList> {
  final TextEditingController _searchCtrl = TextEditingController();
  EventCategory? _selectedCategory;
  bool _showPast = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((e) {
      if (!_showPast && e.isPast) {
        return false;
      }
      if (_selectedCategory != null && e.category != _selectedCategory) {
        return false;
      }
      if (_searchCtrl.text.isNotEmpty &&
          !e.title.toLowerCase().contains(_searchCtrl.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    final sorted = List<Item>.from(filtered)
      ..sort((a, b) => a.starts.compareTo(b.starts));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search...',
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchCtrl.clear(),
              )
                  : null,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: const Text('Past'),
                  selected: _showPast,
                  onSelected: (v) => setState(() => _showPast = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (v) {
                    if (v) {
                      setState(() => _selectedCategory = null);
                    }
                  },
                ),
              ),
              ...EventCategory.values.map(
                    (c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(c.label),
                    selected: _selectedCategory == c,
                    onSelected: (v) {
                      if (v) {
                        setState(() => _selectedCategory = c);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: sorted.isEmpty
              ? const EmptyState(icon: Icons.search_off, message: 'No match')
              : ItemGridOrList(
            items: sorted,
            onTap: (item) {
              Navigator.pushNamed(
                context,
                Routes.detail,
                arguments: DetailArgs(
                  item: item,
                  profile: widget.profile,
                  onToggleFavourite: widget.onToggleFavourite,
                  onRegister: widget.onRegister,
                  onUnregister: widget.onUnregister,
                  onEditItem: widget.onEditItem,
                  onDeleteItem: widget.onDeleteItem,
                  onSwitchTab: widget.onSwitchTab,
                ),
              );
            },
            onToggleFavourite: widget.onToggleFavourite,
          ),
        ),
      ],
    );
  }
}