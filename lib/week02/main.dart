import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  library.add(const Magazine(title: 'Tech Today', year: 2023, issue: 42));
  library.add(const Ghost(title: 'Spooky Specs', year: 1999));

  print('Library Opened At: ${library.openedAt}');
  print('Country of Refactoring: ${library.countryOf('Refactoring')}');
  print('Country of Design Patterns: ${library.countryOf('Design Patterns')}');
  print('Country of Broken Record: ${library.countryOf('Broken Record')}');

  print('All Titles: ${library.allTitles}');
  print('Books Published After 2010: ${library.booksAfter2010.map((b) => b.title).toList()}');
  print('Average Page Count: ${library.averagePageCount.toStringAsFixed(1)}');
  print('Author Book Counts: ${library.authorBookCounts}');
  print('Distinct Authors: ${library.distinctAuthors}');
  print('Distinct Genres: ${library.distinctGenres.map((g) => g.label).toSet()}');

  for (final line in library.displayCatalogue) {
    print(line);
  }

  final booksOnly = library.items.whereType<Book>().toList();
  final stats = statsOf(booksOnly);
  print('Stats Record -> Count: ${stats.count}, Avg Pages: ${stats.avgPages.toStringAsFixed(1)}');

  print(describe(const Empty()));
  print(describe(Ready(booksOnly)));
  print(describe(const Broken('Shelf weight limit exceeded!')));
}