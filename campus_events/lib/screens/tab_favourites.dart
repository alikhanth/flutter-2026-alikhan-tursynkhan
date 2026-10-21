import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_grid_or_list.dart';

class TabFavourites extends StatelessWidget {
  final List<Item> items;
  final Profile profile;
  final Function(Item) onToggleFavourite;
  final Function(Item) onRegister;
  final Function(Item) onUnregister;
  final Function(Item) onEditItem;
  final Function(Item) onDeleteItem;
  final Function(int) onSwitchTab;

  const TabFavourites({
    super.key,
    required this.items,
    required this.profile,
    required this.onToggleFavourite,
    required this.onRegister,
    required this.onUnregister,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites',
      );
    }
    return ItemGridOrList(
      items: items,
      onTap: (item) => Navigator.pushNamed(
        context,
        Routes.detail,
        arguments: DetailArgs(
          item: item,
          profile: profile,
          onToggleFavourite: onToggleFavourite,
          onRegister: onRegister,
          onUnregister: onUnregister,
          onEditItem: onEditItem,
          onDeleteItem: onDeleteItem,
          onSwitchTab: onSwitchTab,
        ),
      ),
      onToggleFavourite: onToggleFavourite,
    );
  }
}