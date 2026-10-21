import 'package:flutter/material.dart';
import '../models/item.dart';
import 'item_card.dart';

class ItemGridOrList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onTap;
  final Function(Item) onToggleFavourite;

  const ItemGridOrList(
      {super.key,
      required this.items,
      required this.onTap,
      required this.onToggleFavourite});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => onTap(items[index]),
              child: ItemCard(
                  item: items[index],
                  onToggleFavourite: () => onToggleFavourite(items[index])),
            ),
          );
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => onTap(items[index]),
            child: ItemCard(
                item: items[index],
                onToggleFavourite: () => onToggleFavourite(items[index])),
          ),
        );
      },
    );
  }
}
