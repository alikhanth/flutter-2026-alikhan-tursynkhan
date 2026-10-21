import 'package:flutter/material.dart';
import '../models/item.dart';
import '../utils/format.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onToggleFavourite;

  const ItemCard(
      {super.key, required this.item, required this.onToggleFavourite});

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = item.places; // R5 Destructuring

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        item.category.color(Theme.of(context).colorScheme),
                    child: Icon(item.category.icon,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  if (item.isFull || free <= 5) // R19 Collection IF
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.isFull ? 'FULL' : '$free left',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onError,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${formatDate(item.starts)} · ${item.location}'),
                ],
              ),
            ),
            IconButton(
              icon:
                  Icon(item.favourite ? Icons.favorite : Icons.favorite_border),
              onPressed: onToggleFavourite,
            ),
          ],
        ),
      ),
    );
  }
}
