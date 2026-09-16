import 'models.dart';

class Library {
  final List<LibraryItem> items = [];
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  String generateReport() => _cachedReport ??=
  'Library report generated on ${DateTime.now()} with ${items.length} items.';

  List<String> get allTitles => items.map((e) => e.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  double get averagePageCount => items.whereType<Book>().isEmpty
      ? 0.0
      : items.whereType<Book>().fold<int>(0, (sum, b) => sum + b.pages) /
      items.whereType<Book>().length;

  Map<String, int> get authorBookCounts =>
      items.whereType<Book>().fold<Map<String, int>>({}, (map, b) {
        map[b.author.name] = (map[b.author.name] ?? 0) + 1;
        return map;
      });

  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get distinctGenres =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayCatalogue => [
    'CATALOGUE',
    for (final book in items.whereType<Book>()) '${book.title} (${book.year})',
    ...items.whereType<Book>().map((b) => b.author.name),
    if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
  ];
}