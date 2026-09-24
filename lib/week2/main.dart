import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  print('--- CATALOGUE REPORT ---');
  print(library.report);

  print('\n--- ALL TITLES ---');
  print(library.allTitles.toList());

  print('\n--- COUNTRY OF "Refactoring" ---');
  print(library.countryOf('Refactoring'));

  print('\n--- COUNTRY OF "Design Patterns" ---');
  print(library.countryOf('Design Patterns'));

  print('\n--- AVERAGE PAGES ---');
  print(library.averagePages.toStringAsFixed(1));

  print('\n--- DISPLAY CATALOGUE LITERAL ---');
  for (final line in library.displayCatalogue) {
    print(line);
  }

  final booksOnly = library.items.whereType<Book>().toList();
  final stats = statsOf(booksOnly);

  print('\n--- STATS (RECORD) ---');
  print('Count: ${stats.count}, Avg Pages: ${stats.avgPages}');

  print('\n--- SHELF STATES (DART 3 PATTERNS) ---');
  print(describeState(Empty()));
  print(describeState(Ready(booksOnly)));
  print(describeState(Broken('Shelf collapsed under weight')));
}