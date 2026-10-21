import 'dart:async';
import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';

class DetailScreen extends StatefulWidget {
  final DetailArgs args;
  const DetailScreen({super.key, required this.args});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Timer _timer;
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.args.item;
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onItemUpdated(Item newItem) {
    setState(() => _item = newItem);
    widget.args.onEditItem(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final countdown = getCountdown(_item.starts);
    final String countdownText = switch (countdown) {
      Upcoming(duration: final d) => 'In ${d.inDays}d ${d.inHours % 24}h',
      Started(duration: final d) => 'Started ${d.inMinutes}m ago',
      Ended() => 'Ended',
    };

    final isRegistered = _item.contains(widget.args.profile.name);
    final desc = _item.description;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_item.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.pushNamed<Item>(
                  context,
                  Routes.form,
                  arguments: FormArgs(_item),
                );
                if (!context.mounted) {
                  return;
                }
                if (result != null) {
                  _onItemUpdated(result);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) {
                  return;
                }
                if (confirm == true) {
                  widget.args.onDeleteItem(_item);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 24 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/header.jpg',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(
                      avatar: Icon(_item.category.icon),
                      label: Text(_item.category.label),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Chip(label: Text(countdownText)),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_item.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${formatDate(_item.starts)}'),
                        Text('Place: ${_item.location}'),
                        Text('Places: ${_item.count}/${_item.capacity}'),
                        if (desc != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(desc),
                          ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    itemCount: _item.attendees.length,
                    itemBuilder: (context, index) {
                      final name = _item.attendees[index];
                      final isYou = name == widget.args.profile.name;
                      return ListTile(
                        title: Text(
                          isYou ? 'You' : name,
                          style: isYou
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (_item.isFull && !isRegistered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('the event is full')),
              );
              return;
            }

            if (widget.args.profile.name.isEmpty) {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(context);
              messenger.showSnackBar(SnackBar(
                content: const Text('Profile name is empty'),
                action: SnackBarAction(
                  label: 'Profile',
                  onPressed: () {
                    nav.pop();
                    widget.args.onSwitchTab(2);
                  },
                ),
              ));
              return;
            }

            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(isRegistered ? 'Unregister?' : 'Register?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
            if (!context.mounted) {
              return;
            }
            if (confirm == true) {
              if (isRegistered) {
                widget.args.onUnregister(_item);
                setState(() {
                  _item = _item.copyWith(
                    attendees: _item.attendees
                        .where((n) => n != widget.args.profile.name)
                        .toList(),
                  );
                });
              } else {
                widget.args.onRegister(_item);
                setState(() {
                  _item = _item.copyWith(
                    attendees: [..._item.attendees, widget.args.profile.name],
                  );
                });
              }
            }
          },
          label: Text(isRegistered ? 'Unregister' : 'Register'),
          icon: Icon(isRegistered ? Icons.cancel : Icons.how_to_reg),
        ),
      ),
    );
  }
}