# LambdaNative cheat sheet

This sheet describes the API and build conventions used by this repository's
pinned LambdaNative revision. Treat the local framework source as the final
reference when an example from a newer tutorial behaves differently.

## 1. Explain the stack

```text
Scheme app: UI rules, validation, navigation and transactions
    ↓
LambdaNative modules: eventloop, glGUI, uiform, SQLite, core services
    ↓
Gambit compilation + C/native libraries + platform loader
    ↓
Linux executable or Android APK
```

LambdaNative is an open-source framework for native applications across multiple
platforms; Scheme is the language used for much of the app. See the
[official overview](https://www.lambdanative.org/).

This Linux preview is a native desktop build, not an Android emulator. It shares
app source with Android, but cannot prove Android permissions, lifecycle, ABI
compatibility or touch behavior. Test both platforms.

## 2. Repository and framework are different directories

```text
expense-tracker/
├── LambdaNativeQuickStart/                 # our app Git repository
│   ├── ExpenseTracker/
│   │   ├── main.scm                       # application source
│   │   ├── MODULES                        # requested framework modules
│   │   ├── FONTS                          # generated font configuration
│   │   ├── VERSION                        # app version
│   │   └── artwork.png                    # source artwork
│   ├── .github/workflows/build.yml         # CI build
│   ├── tools/                             # local build helpers
│   ├── tests/                             # SQLite + mocked-widget checks
│   ├── docs/                              # these notes
│   └── .local-build/                       # generated, ignored output
└── lambdanative/                           # separate framework checkout
    ├── apps/ExpenseTracker/                # build helper copies our app here
    ├── modules/
    ├── libraries/
    ├── loaders/
    ├── targets/
    ├── SETUP
    └── PROFILE
```

Edit `LambdaNativeQuickStart/ExpenseTracker/main.scm`. Editing only the copied
file under `lambdanative/apps` will be overwritten the next time the helper runs.

`MODULES` currently contains:

```text
eventloop ln_glgui ln_core uiform sqlite
```

| Module | What to point out |
|---|---|
| `eventloop` | Startup and input/lifecycle callbacks |
| `ln_core` | Paths, logging and general framework services |
| `ln_glgui` | Boxes, text, buttons, scrolling lists and GUI events |
| `uiform` | Declarative forms, pages and text/keypad interaction |
| `sqlite` | Native SQLite bindings for persistent data |

Modules can bring additional dependencies; the requested list is not necessarily
the full list of code/native libraries built.

## 3. Application lifecycle

The actual `main` at the bottom of `ExpenseTracker/main.scm` supplies five
callbacks, conceptually:

```scheme
(main
  (lambda (w h) ; initialize logs, window, database and initial view
    ...)
  (lambda (event-type x y) ; route input to the active GUI
    ...)
  (lambda () ; close the database at shutdown
    ...)
  (lambda () (glgui-suspend))
  (lambda () (glgui-resume)))
```

The ellipses are explanatory placeholders; this is not a runnable example.

The app's initialization order is intentional:

1. Create the log directory if missing, then enable/reset logging.
2. Request a `480 × 800` window and portrait orientation.
3. Open `expense.sqlite` beneath `system-directory`.
4. Create or migrate the table.
5. Draw Overview and record the initialized marker.

Do not draw a widget whose dynamic label queries SQLite before the database is
ready. On Android, suspend/resume and application shutdown are different events;
do not close the database merely because the app is temporarily backgrounded.

## 4. Drawing coordinates and widgets

In the app's glGUI layout, `(0, 0)` is at the bottom-left. X grows rightward and
Y upward. Many desktop screenshot tools instead count Y downward from the top.
The app asks `glgui-width-get` and `glgui-height-get` for the current dimensions
instead of assuming a phone screen is exactly `480 × 800`.

Illustrative code for use inside an initialized LambdaNative app:

```scheme
(define g (make-glgui))
(define panel (glgui-box g 24 100 432 148 (color-rgb 24 35 50)))
(glgui-widget-set! g panel 'rounded #t)

(define caption
  (glgui-label g 40 210 400 24 "Available balance" heading_14.fnt expense-ink))
```

The font and color names above come from this app. They are not standalone REPL
variables. For actual examples, read `expense-label`, `expense-card` and
`expense-button` in `main.scm`.

| Task | API/pattern in this app |
|---|---|
| Create a GUI | `(make-glgui)` |
| Draw a background/card | `glgui-box` then set properties |
| Label | `glgui-label` |
| Button | `glgui-button-string` with a procedure callback |
| Read/set a widget property | `glgui-widget-get` / `glgui-widget-set!` |
| Dispatch an event | `(glgui-event active-gui t x y)` |
| Scrollable custom rows | `glgui-list` with drawing procedures and a selection callback |

Widget IDs refer to objects inside a particular GUI. Pass the matching GUI when
reading or setting them. A callback should do its work when clicked, not while
you construct the button: pass a procedure rather than its immediate result.

## 5. uiform pages and dynamic fields

The app mixes custom-drawn dashboard screens with a declarative form. A page has
a title, previous-navigation item, next-navigation item, then a flat sequence
of widget declarations. An illustrative shape:

```scheme
(list->table
  `((main "New transaction" #f #f
      (label text "Amount in KES" align left)
      (textentry id amount text "" keypad numfloat location ui default "0.00")
      (button text "Save" action ,expense-save-form!))))
```

`list->table`/`make-table` are Gambit facilities used here. `uiget` reads active
form values during uiform evaluation/callbacks; it is not a universal global
store for all application screens.

```scheme
(uiget 'amount "")
(glgui-widget-set! entry-gui form 'category "Other")
```

This pinned uiform supports the flat widget sequences used here. Do not assume
HTML tags, CSS, nested layout widgets or APIs from another GUI framework work.
Font selection is driven by properties such as `size small`, `size big` and
`size header`, and the form's configured font properties.

For Other, two procedures return either a custom-category label/textentry or a
zero-height spacer. Category selection clears `nodemap` so the form recalculates
the click and scroll layout when its content changes. The type-change handler
also resets category/custom-name state when needed.

For this pinned implementation, preserve `headerh` as `88.0` in the entry form.
Its drawing code uses floating-point operations; changing it to integer `88`
previously caused a runtime type error. This is a concrete framework-version
detail, not a rule that every GUI dimension must be inexact.

## 6. Navigation and state

| State | Meaning |
|---|---|
| `expense-view` | `overview`, `activity`, `entry` or `categories` |
| `expense-filter` | Activity's All/Income/Expense selection |
| `expense-return-view` | Dashboard to return to after a form operation |
| `expense-edit-id` | Saved row being edited, or `#f` for a new record |
| Form `page` | `main` editor or `delete` confirmation page |
| `entry-gui` / `expense-picker-gui` / `gui` | Separate GUI objects for the screens |

`expense-show-view!` creates the dashboard GUI and re-queries totals/rows.
Saving or deleting returns to that function, which refreshes displayed values.
Activity's filter remains selected; changing an Income record to Expense can
make it disappear from an Income-only list. That is expected, not data loss.

The event callback routes input according to the active view. Escape/Android
Back dismisses the keypad first, backs out of confirmation or category choice,
returns to the originating dashboard, or exits from Overview.

## 7. Fonts and assets

Current `FONTS`:

```text
DejaVuSans.ttf 7 12,14,16 body
DejaVuSans-Bold.ttf 7 12,14,16,18,22,28,36 heading
```

The build generates names such as `body_16.fnt` and `heading_28.fnt`. These are
build-generated resources, not arbitrary font names resolved at runtime. If code
refers to a font not generated by `FONTS`, fix the configuration and rebuild.
The `7` field is part of the framework font recipe; consult its tools before
changing it rather than interpreting it as a CSS setting.

For a design exercise, start with an SVG source asset and keep its editable
source. The existing app artwork is PNG; an SVG delivered by a designer is not
automatically loaded by this app. Plan a supported conversion/embedding step
and check the framework's texture/artwork pipeline before integration.

## 8. Persistence and the SQLite wrapper

`system-directory` is the app's platform-specific data location. `db` is a
SQLite connection. The form's `(make-table)` database property is a separate
form data structure; it is not the SQLite database file.

`sqlite-query` in this pinned wrapper produces a list of rows for SELECT,
usually an empty list for successful writes, and `#f` if statement preparation
fails. The wrapper does not expose all execution-step errors robustly: “write
returned an empty list” is not a full transactional guarantee. This is a useful
future binding-improvement topic. The app raises on `#f`, catches exceptions in
save/delete handlers, and tests expected resulting data.

The native integer result conversion uses a C `int`/`atoi` path. Monetary cents,
totals and row IDs are therefore selected as TEXT and converted in Scheme.
Keep this protection when modifying SQL.

Migration retains the original `amount` column, adds `amount_cents`, `category`
and `created_at`, and backfills missing cents in a transaction. Existing rows
receive category General and a blank date rather than an invented timestamp.

## 9. Building and platform differences

Use the [command guide](commands-and-troubleshooting.md) for runnable commands.
Conceptually, building inside the framework uses:

```sh
./configure ExpenseTracker linux debug
make
```

Android additionally needs the SDK, NDK, Java, Ant/native toolchain, signing key
and platform loader. The local Docker helper assembles these and builds Linux
host tools before Android. It is a build environment, not a phone emulator.

The local package is `com.yourdomainhere.workshop.expensetracker`, displayed as
ExpenseTracker Workshop. The default baseline package is
`com.yourdomainhere.expensetracker`. They have separate data stores.

`ANDROIDAPI=28` is the native/minimum build setting here. The pinned manifest
declares target SDK 31 separately. Minimum SDK, target SDK, build tools, CPU ABI
and Android OS version are distinct concepts. Do not promise that updating one
automatically fixes a compatibility warning or crash.

## 10. F-Droid talking points

[F-Droid](https://f-droid.org/en/about/) distributes free/open-source Android
software. An APK built by this repository or GitHub Actions is not automatically
published on F-Droid. Inclusion has its own review, licensing, metadata and build
requirements; refer to the [inclusion policy](https://f-droid.org/docs/Inclusion_Policy/).

For the comparison exercise, ask what a feature does for the user: easier input,
clearer balances, useful categories, export, privacy, accessibility and recovery.
Let participants choose apps rather than claiming a fixed shortlist is current.

## Questions you may be asked

- **Why not run Scheme directly on the phone?** This project packages compiled
  Scheme, native dependencies and a platform loader into an APK.
- **Can we make a modern UI?** Yes: current cards, colors, typography, forms and
  custom lists demonstrate the available drawing/widget approach. Refinement
  still requires layout, touch, accessibility and platform testing.
- **Does this have login or cloud sync?** No. Current storage is local; login,
  backup/export and synchronization are future features.
- **Can a Windows learner participate?** They can review code, practice Scheme,
  submit issues and use hosted builds. These local shell helpers target a Linux
  setup; they are not verified Windows or macOS installation guides.
- **Will this APK work on every Android phone?** Not guaranteed. Inspect ABIs,
  SDK behavior, logs and actual device tests.
