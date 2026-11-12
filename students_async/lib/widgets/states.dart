import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text("Loading students..."),
      ],
    ),
  );
}

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Could not load students"),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
      ],
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text("No students yet"));
}

class StudentList extends StatelessWidget {
  final List<Student> students;
  final bool compact;
  const StudentList(this.students, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final s = students[index];
        return ListTile(
          dense: compact,
          title: Text(s.name),
          subtitle: Text(s.group),
          trailing: Text(s.gpa?.toString() ?? "—"),
        );
      },
    );
  }
}
