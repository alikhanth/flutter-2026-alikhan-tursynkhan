import 'package:flutter/material.dart';
import 'models/item.dart';
import 'models/profile.dart';
import 'screens/detail.dart';
import 'screens/form.dart';

class Routes {
  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case detail:
        final args = settings.arguments as DetailArgs;
        return MaterialPageRoute<void>(
          builder: (_) => DetailScreen(args: args),
          settings: settings,
        );
      case form:
        final args = settings.arguments as FormArgs;
        return MaterialPageRoute<Item>(
          builder: (_) => FormScreen(args: args),
          settings: settings,
        );
    }
    return null;
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Not found')),
      ),
      settings: settings,
    );
  }
}

class DetailArgs {
  final Item item;
  final Profile profile;
  final Function(Item) onToggleFavourite;
  final Function(Item) onRegister;
  final Function(Item) onUnregister;
  final Function(Item) onEditItem;
  final Function(Item) onDeleteItem;
  final Function(int) onSwitchTab;

  DetailArgs({
    required this.item,
    required this.profile,
    required this.onToggleFavourite,
    required this.onRegister,
    required this.onUnregister,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onSwitchTab,
  });
}

class FormArgs {
  final Item? item;
  FormArgs(this.item);
}