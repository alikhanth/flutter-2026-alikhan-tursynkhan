import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
          );
        },
        tooltip: 'New user',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context, m),
    );
  }

  Widget _buildBody(BuildContext context, UsersModel m) {
    if (m.loading) {
      return const LoadingView();
    }

    return switch (m.error) {
      null => RefreshIndicator(
        onRefresh: m.load,
        child: UserList(users: m.items),
      ),
      NoConnectionException() => OfflineView(onRetry: m.load),
      NotFoundException() => RequestErrorView(
        message: 'The requested users resource was not found (404).',
        onRetry: m.load,
      ),
      UnauthorizedException() => RequestErrorView(
        message: 'You are not authorized to view this resource (401).',
        onRetry: m.load,
      ),
      ServerException(:final status) => ServerErrorView(
        status: status,
        onRetry: m.load,
      ),
      BadResponseException(:final detail) => GenericErrorView(
        detail: detail,
        onRetry: m.load,
      ),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class OfflineView extends StatelessWidget {
  const OfflineView({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No network connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async => onRetry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestErrorView extends StatelessWidget {
  const RequestErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerErrorView extends StatelessWidget {
  const ServerErrorView({
    required this.status,
    required this.onRetry,
    super.key,
  });

  final int status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'Server error ($status)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'The server encountered an issue. Please try again shortly.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class GenericErrorView extends StatelessWidget {
  const GenericErrorView({this.detail, required this.onRetry, super.key});

  final String? detail;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bug_report_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Unexpected response format',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(detail ?? '', textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async => onRetry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({required this.users, super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${user.id}')),
          title: Text(user.name),
          subtitle: Text('${user.email} • ${user.address.city}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: user),
              ),
            );
          },
        );
      },
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final website = user.website;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Username'),
            subtitle: Text('@${user.username} (ID: ${user.id})'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Phone'),
            subtitle: Text('${user.phone} (digits: ${user.phoneDigits})'),
            onTap: () {}, // Wired to url_launcher in Practice 12
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Website'),
            subtitle: Text(website ?? 'Not provided'),
            onTap: website == null ? null : () {}, // Wired in Practice 12
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Address'),
            subtitle: Text(
              '${user.address.street}, ${user.address.suite}\n'
              '${user.address.city}, ${user.address.zipcode}\n'
              'Geo: (${user.address.geo.lat}, ${user.address.geo.lng})',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final draft = User(
      id: 0,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: '000-000-0000',
      address: const Address(
        street: '123 Main St',
        suite: 'Apt. 1',
        city: 'Almaty',
        zipcode: '050000',
        geo: Geo(lat: 43.2389, lng: 76.8897),
      ),
      company: (
        name: 'New Venture',
        catchPhrase: 'Building clean Dart clients',
      ),
    );

    try {
      await context.read<UsersModel>().createUser(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = switch (e) {
        NoConnectionException() => 'No connection. Check network and retry.',
        ServerException(:final status) => 'Server error ($status). Try again.',
        BadResponseException(:final detail) =>
          'Invalid response${detail != null ? ': $detail' : ''}',
        NotFoundException() => 'Endpoint not found (404).',
        UnauthorizedException() => 'Unauthorized request (401).',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final creating = context.select<UsersModel, bool>((m) => m.creating);

    return Scaffold(
      appBar: AppBar(title: const Text('New User')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              enabled: !creating,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              enabled: !creating,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Username is required';
                }
                if (trimmed.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: !creating,
              onFieldSubmitted: (_) async {
                if (!creating) await _submit();
              },
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(trimmed)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: creating ? null : _submit,
              child: creating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
