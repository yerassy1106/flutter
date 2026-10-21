# Practice 8 — A Little of Everything (Reading List)

Mobile Development, KBTU. A recap of weeks 1–7 in one small app.

| Level | Topic | File |
| --- | --- | --- |
| 1 | Dart, no widgets: `fromMap`, `toString`, `fold` / `where` / `toSet` | `lib/models/book.dart` |
| 2 | State + filter: enum, switch expression, `ChoiceChip`, `ListView.builder` | `lib/library_screen.dart` |
| 3 | Layout: `BookTile` (Row / Stack / Expanded / ellipsis), stats header | `lib/widgets/book_tile.dart` |
| 4 | Navigation that answers: `push<BookAction>`, `showDialog<bool>`, `mounted` | `lib/detail_screen.dart` |
| 5 | Validated form: `push<Book>`, four validators, `int.tryParse` | `lib/add_book_screen.dart` |

Console at startup: `1220 pages, 4 unread` and `X — Y, 10 pp.`

## Run

```bash
flutter create .          # generates android/ ios/ web/ ... (lib/ and pubspec are kept)
flutter pub get
flutter run
flutter analyze
dart format .
flutter test
```

## Screenshots

Add before submitting (see `screenshots/`):

- `screenshot_list.png` — filter on Unread, long title wrapped
- `screenshot_form.png` — the form with its three errors
