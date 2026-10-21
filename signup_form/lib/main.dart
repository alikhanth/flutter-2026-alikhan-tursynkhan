import 'package:flutter/material.dart';
import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController(); // To display the formatted date

  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() {
        _done = true;
      });
    }
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthController]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done
        ? SingleChildScrollView(
      child: Column(
        children: [
          SummaryCard(
            name: _name.text,
            email: _email.text,
            group: _group!,
            birthDate: _birthController.text,
          ),
          TextButton(
            onPressed: _startOver,
            child: const Text('Start over'),
          ),
        ],
      ),
    )
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v ?? '').trim().length < 2 ? 'Name is too short' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              validator: (v) =>
              (v ?? '').contains('@') && (v ?? '').contains('.') ? null : 'Email looks wrong',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.next,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Password',
                helperText: 'At least 8 characters',
              ),
              validator: (v) => (v ?? '').length < 8 ? 'Password is too short' : null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${_password.text.length} of 8',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              onFieldSubmitted: (_) {
                if (_agreed) _signUp();
              },
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (v) => v == _password.text ? null : 'Passwords do not match',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _group,
              decoration: const InputDecoration(labelText: 'Group'),
              items: groups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _group = v),
              validator: (v) => v == null ? 'Choose a group' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (v) => _birth == null ? 'Choose a date' : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birth ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked == null) return;
                if (!mounted) return;
                setState(() {
                  _birth = picked;
                  _birthController.text =
                  '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                });
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('I agree to the rules'),
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24), // Explicit requirement, not a Spacer
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _agreed ? _signUp : null, // Framework handles disabling
                child: const Text('Sign up'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}