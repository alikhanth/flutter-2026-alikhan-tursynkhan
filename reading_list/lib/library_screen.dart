import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${_visible.length})')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_books.length}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Books', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${totalPages(_books)}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Pages', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${unread(_books).length}',
                          style: textTheme.headlineSmall,
                        ),
                        Text('Unread', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Filter.values.map((f) {
                final label = f.name[0].toUpperCase() + f.name.substring(1);
                return ChoiceChip(
                  label: Text(label),
                  selected: _filter == f,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _filter = f);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _visible.length,
              itemBuilder: (context, index) {
                final book = _visible[index];
                return InkWell(
                  onTap: () async {
                    final action = await Navigator.of(context).push<BookAction>(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(book: book),
                      ),
                    );

                    if (!mounted) return;

                    if (action == BookAction.toggleRead) {
                      setState(() => book.read = !book.read);
                    } else if (action == BookAction.delete) {
                      setState(() => _books.remove(book));
                    }
                  },
                  child: BookTile(
                    book: book,
                    onToggle: () {
                      setState(() => book.read = !book.read);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBook = await Navigator.of(context).push<Book>(
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );

          if (!mounted || newBook == null) return;

          setState(() {
            _books.add(newBook);
          });
        },
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
