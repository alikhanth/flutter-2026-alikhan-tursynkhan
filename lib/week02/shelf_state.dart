import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  final List<Book> books;
  const Ready(this.books);
}

final class Broken extends ShelfState {
  final String message;
  const Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
  Empty() => 'The shelf is empty.',
  Ready(:final books) => 'The shelf has ${books.length} books ready.',
  Broken(:final message) => 'The shelf is broken: $message',
};

({int count, double avgPages}) statsOf(List<Book> books) {
  if (books.isEmpty) return (count: 0, avgPages: 0.0);
  final totalPages = books.fold<int>(0, (sum, b) => sum + b.pages);
  return (count: books.length, avgPages: totalPages / books.length);
}