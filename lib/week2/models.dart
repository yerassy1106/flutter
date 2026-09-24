enum Genre {
  craft('Craftsmanship'),
  theory('Software Theory'),
  unknown('Unknown Genre');

  final String label;
  const Genre(this.label);

  factory Genre.fromString(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'craft':
        return Genre.craft;
      case 'theory':
        return Genre.theory;
      default:
        return Genre.unknown;
    }
  }
}

class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  @override
  String toString() => 'Author(name: $name, country: ${country ?? "Unknown"})';
}


abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  String describe();

  bool get isOld => DateTime.now().year - year > 20;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'BORROW: "$title" ($year)';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });


  factory Book.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Untitled';
    final year = json['year'] as int? ?? 0;
    final pages = json['pages'] as int? ?? 0;
    final authorName = json['author'] as String? ?? 'Unknown Author';
    final country = json['country'] as String?;
    final genreRaw = json['genre'] as String?;
    final description = json['description'] as String?;

    return Book(
      title: title,
      year: year,
      pages: pages,
      author: Author(name: authorName, country: country),
      genre: Genre.fromString(genreRaw),
      description: description,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String describe() => 'Book "$title" by ${author.name} ($year, $pages pages)';

  @override
  String toString() =>
      'Book(title: $title, year: $year, pages: $pages, author: $author, genre: $genre)';
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() => 'Magazine "$title" Issue #$issue ($year)';
}


class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  Ghost(this.title, this.year);

  @override
  String describe() => 'Ghost Item: $title ($year)';

  @override
  bool get isOld => DateTime.now().year - year > 20;
}