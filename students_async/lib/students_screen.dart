import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/states.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  final _api = FakeApi();
  bool _saving = false; // Level 5

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });

    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  // Level 5 Save function
  Future<void> _handleSave() async {
    if (_students == null) return;
    setState(() => _saving = true);

    try {
      await _api.save(_students!.length);
      if (!mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('By Hand')),
      body: body,
      // Level 5 Save Button
      floatingActionButton: _students != null && _error == null
          ? FloatingActionButton(
              onPressed: _saving ? null : _handleSave,
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
            )
          : null,
    );
  }
}
