import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/auth/auth_model.dart';
import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

void main() {
  testWidgets('UsersScreen renders app bar', (WidgetTester tester) async {
    final client = http.Client();
    addTearDown(client.close);
    const store = SecureStore();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SettingsModel(SharedPreferencesAsync(), dark: false),
          ),
          ChangeNotifierProvider(
            create: (_) => AuthModel(store, initialToken: 'tok_test'),
          ),
          ChangeNotifierProvider(
            create: (_) => UsersModel(
              UserRepository(ApiClient(client, store), UsersCache()),
            ),
          ),
        ],
        child: const MaterialApp(home: UsersScreen()),
      ),
    );

    expect(find.text('Users'), findsOneWidget);
  });
}
