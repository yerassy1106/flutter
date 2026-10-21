# Practice 7 — A Form That Validates Itself

Mobile Development, KBTU. One screen: a sign-up form built with `Form`, `TextFormField`
and a validator beside every field, one `validate()` on the button.

## What is inside

| Level | Topic | Where |
| --- | --- | --- |
| 1 | The if-chain → controllers, decorations, live "N of 8" counter | `lib/main.dart` |
| 2 | `Form` + `GlobalKey<FormState>`, 5 validators, `onUserInteraction` | `lib/main.dart` |
| 3 | `FocusNode`, `textInputAction`, `onTapOutside`, `SingleChildScrollView` | `lib/main.dart` |
| 4 | Group dropdown, date picker, checkbox → `onPressed: null` | `lib/main.dart` |
| 5 | `SummaryCard` with `LayoutBuilder` (breakpoint 600 px), "Start over" | `lib/summary_card.dart` |

## Run

```bash
flutter create .          # generates android/ ios/ web/ ... (lib/ and pubspec are kept)
flutter pub get
flutter run
flutter analyze
dart format .
flutter test
```

Requires Flutter 3.35+ (`DropdownButtonFormField.initialValue`).

## Screenshots

Add before submitting (see `screenshots/`):

- `keyboard_open.png` — the form with the keyboard open on *Confirm password*, no stripes
- `tablet.png` — the summary in two columns
