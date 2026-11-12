# Practice 10 — The Data Arrives Later: NOTES

## Level 1 — order of events

Experiment in `main()` (removed afterwards):

```dart
print('A');
Future.delayed(const Duration(seconds: 2), () => print('B'));
print('C');
final api = FakeApi();
api.fetchStudents().then((l) => print('${l.length} students'));
runApp(...);
```

**Predicted:**

1. `A`
2. `C`
3. (first frame of the app is drawn)
4. after 2 s: `B`
5. right after: `6 students`

Reason: `main()` runs to the end without waiting. The two timers are events
in the queue; `B`'s timer was created first, so it fires first.

**Actual:** <!-- paste your real console output here -->

```
A
C
B
6 students
```

`sleep(const Duration(seconds: 2))` instead of `await Future.delayed(...)`:
the first frame is not drawn for 2 seconds — the loop is blocked, not waiting.

Calling `fetchStudents()` three times from `main()`: the third call prints
`Unhandled Exception: Instance of 'NoConnectionException'` and the app keeps
running (nobody awaits that Future).

## Level 2 — setState() after dispose

Both `if (!mounted) return;` removed, Back pressed within 2 seconds. First line
of the error:

```
<!-- paste your exact line, it looks like: -->
setState() called after dispose(): _StudentsScreenState#xxxxx(lifecycle state: defunct, not mounted)
```

The guards were put back.

## Level 3 — FutureBuilder

- Switch flipped 10 times: the console shows one `fetchStudents #1`.
- With `future: _api.fetchStudents()` inline in `build`: a spinner on every
  flip, the console counts `#2 #3 #4 …`, the third one fails.
- With `hasData` checked before `hasError`: a spinner forever on failure.

## Level 4 — the countdown

- **Without `_sub.cancel()` (version B):** Back at 7 → one second later
  `setState() called after dispose()`, and the console keeps printing
  `tick 6, tick 5 … tick 0` with nobody on screen. That is the leak.
- **Version A (StreamBuilder):** Back at 7 → the console stops at `tick 7`.
  StreamBuilder cancels the subscription for us.
- **With `_sub.cancel()` in `dispose` (version B):** the console stops at `tick 7`.

## Level 5 — errors that do not vanish

The naive version `onPressed: () { _api.save(n); Navigator.pop(context); }`:
`flutter analyze` flags it with `unawaited_futures`. The second tap pops the
screen as if it worked, and the console says:

```
Unhandled Exception: Bad state: server rejected 6
```

**The user saw a success, and the error vanished into the console.**

The honest version: `await` + `try / on StateError`, `context.mounted` after the
await, pop only on success, the error text in a SnackBar, and the button is
disabled with a spinner while the request is in flight.

## Three questions when async "does not work"

1. Is the Future stored, or created in `build`? (flicker → created in build)
2. Is the line after `await` guarded with `mounted`? (setState after dispose)
3. Does anybody `await` this Future? (Unhandled Exception in the console)
