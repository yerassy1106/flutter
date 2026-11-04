# Lab Notes: Practice 9 - Put It High, Subscribe Low

## Level 1: Lifted State Measurements
* **Constructors modified for `total` parameter propagation:** 4 constructors across 3 files (`Shell` -> `BooksScreen` -> `AppBar` actions -> `CartBadge`).
* **Console lines printed on single `Add` tap:** 7 lines (1 for `BooksScreen build` + 6 for each `row [Title]`). Single `setState` at the root invalidates the entire child tree under `Shell`.

## Level 3: Provider Error Messages
* **Loud Error (`watch` called in callback / outside build):**
  > Error: Tried to listen to a value exposed with provider, from outside of the widget tree.
  > This is likely caused by calling Provider.of(context) or context.watch inside a button onPressed callback or lifecycle methods.
* **Silent Error (`read` called in `build`):**
  > No exception raised. The UI renders the initial value (0), but never updates when changes occur because the widget registered no listener on the provider.

## Level 4: Rebuild Tracking (`CartBadge`)
* **With `context.watch<Cart>()`:** 3 rebuilds on pressing `+` on a cart item (rebuilds even though total count remains unchanged).
* **With `context.select<Cart, int>((c) => c.count)`:** 0 rebuilds on pressing `+` (only rebuilds when unique item count changes).

## Level 5: Where Does It Live?
1. **The Cart (`Cart` class):** Provided (App-wide business logic state managed via `ChangeNotifierProvider`).
2. **Search field text in Books AppBar:** Ephemeral (Local widget state using `TextEditingController` or `StatefulWidget` since only the search bar UI cares about raw keystrokes).
3. **Cart Screen total expanded/collapsed:** Ephemeral (Local UI state managed via `setState` in a `StatefulWidget`).
4. **Theme mode (Dark/Light switch):** Provided (App-wide configuration state placed above `MaterialApp` to control global app appearance).