import 'package:flutter/material.dart';
import 'routes.dart';
import 'screens/shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Events',
      themeMode: _themeMode,
      // Uses a base hex for the required 'seedColor' strictly without 'Colors.x' scattered across code.
      theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF6200EE))),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6200EE), brightness: Brightness.dark)),
      routes: {
        Routes.shell: (context) => ShellScreen(
              themeMode: _themeMode,
              onThemeChanged: (mode) => setState(() => _themeMode = mode),
            ),
      },
      onGenerateRoute: Routes.onGenerateRoute,
      onUnknownRoute: Routes.onUnknownRoute,
    );
  }
}
