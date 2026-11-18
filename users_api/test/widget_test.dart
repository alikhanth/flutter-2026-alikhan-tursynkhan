import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

void main() {
  testWidgets('UsersScreen renders app bar', (WidgetTester tester) async {
    final client = http.Client();
    addTearDown(client.close);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UsersModel(UserRepository(ApiClient(client))),
        child: const MaterialApp(home: UsersScreen()),
      ),
    );

    expect(find.text('Users'), findsOneWidget);
  });
}
