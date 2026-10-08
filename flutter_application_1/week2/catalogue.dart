import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;
  String? _cachedReport;

  void open() {
    openedAt = DateTime.now();
  }

  void add(LibraryItem item) {
    items.add(item);
  }

  

  Book? findByTitle(String title) {
    final matches = items.whereType<Book>().where((b) => b.title == title);
    return matches.isEmpty ? null : matches.first;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  String get report {
    final cached = _cachedReport;
    if (cached != null) return cached;
    final newReport = 'Library Report (Opened at: $openedAt)';
    _cachedReport = newReport;
    return newReport;
  }


  Iterable<String> get allTitles => items.map((item) => item.title);


  Iterable<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010);

 
  double get averagePages => items.whereType<Book>().isEmpty
      ? 0.0
      : items.whereType<Book>().fold<int>(0, (sum, book) => sum + book.pages) /
          items.whereType<Book>().length;


  Map<String, int> get authorBookCounts => items.whereType<Book>().fold<Map<String, int>>(
        {},
        (map, book) => map..[book.author.name] = (map[book.author.name] ?? 0) + 1,
      );


  Set<String> get uniqueAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();


  Set<Genre> get presentGenres =>
      items.whereType<Book>().map((b) => b.genre).toSet();

 
  List<String> get displayCatalogue => [
        'CATALOGUE',
        for (final book in items.whereType<Book>()) '${book.title} (${book.year})',
        ...uniqueAuthors,
        if (items.whereType<Book>().any((b) => b.pages == 0)) '(incomplete data)',
      ];
}