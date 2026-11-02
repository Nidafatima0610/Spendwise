# SpendWise — Day 1 Daily Progress Submission Package
**Stack & Scale Remote Internship 2026 | Week 02 — Mobile Engineering Track**  
**Project:** SpendWise – Personal Budget & Expense Tracker  
**Date:** Monday, November 02, 2026  
**Status:** Complete Day 1 Foundation Delivered  

---

## 1. Project Title & Internship Details
* **Project Name:** SpendWise – Personal Budget & Expense Tracker
* **Internship Program:** Stack & Scale Remote Internship 2026
* **Curriculum Track:** Week 02 — Mobile App Architecture, Offline-First SQLite, and Fintech UI/UX
* **Core Technology Stack:** Flutter 3.47.1, Dart 3.13.1, Material 3, SQLite (`sqflite` + `sqflite_common_ffi`), `intl`

SpendWise is an offline-first personal finance application tailored for students and early-career professionals to manage their income, expenses, monthly category budgets, and spending habits without cloud dependencies, paid APIs, or third-party bank integrations.

---

## 2. Monday's Objectives & Completed Tasks
* [x] **Four-Screen UI Foundation:** Implemented Dashboard, Add Transaction, Transaction History, and Budgets, plus a Settings/System Status screen.
* [x] **Working Navigation Architecture:** Implemented a 5-destination bottom navigation bar with active state pills and persistent tab state via `IndexedStack`.
* [x] **Fintech Minor-Units Standard:** Designed `TransactionModel` and `CategoryModel` with monetary figures stored strictly as integers in minor currency units (paisas) to eliminate floating-point rounding errors.
* [x] **Centralized PKR Currency Configuration:** Documented and configured Pakistani Rupee (PKR / Rs.) with centralized formatting logic.
* [x] **SQLite Database Infrastructure:** Implemented `AppDatabase` singleton, created tables (`categories`, `transactions`, `budgets`), enabled foreign key constraints via `PRAGMA foreign_keys = ON;`, created index optimizations, and pre-seeded 11 default categories.
* [x] **Desktop & Cross-Platform Test Support:** Integrated `sqflite_common_ffi` with automated platform detection, allowing unit tests and desktop builds to execute alongside Android.
* [x] **Verification & Quality:** Verified 100% clean `flutter analyze` (0 errors, 0 warnings) and 100% passing tests (6/6 tests).
* [x] **Device Execution:** Built and installed APK on physical Pixel 6 Pro device; captured genuine screenshot evidence.

---

## 3. Overview of Premium Fintech UI Design
The UI follows a modern, sophisticated fintech design language:
* **Brand Colors:** Sophisticated violet/purple brand identity (`#6536C7`) with deep indigo accents (`#4F28A4`) and soft lavender surfaces (`#F8F6FE`, `#F6F4FC`).
* **Semantic Accents:** Emerald Green (`#10B981`) for positive cash flow / income, Coral Red (`#EF4444`) for expenditures, and Amber (`#F59E0B`) for budget threshold warnings.
* **Component Styling:** Consistent 22px rounded cards, multi-layered subtle shadows, high-contrast typography, and responsive spacing.
* **Strict Data Separation:** All sample figures are explicitly badged with a "Preview Mode" banner so sample data is never confused with real user records.

---

## 4. Main Screens Completed

### Screen A: Dashboard (`DashboardScreen`)
* Personalized header ("Welcome back, Alex Rivera 👋") with user initials badge and regional indicator.
* Month selector pill ("November 2026 ▾").
* Total balance card (`PKR 143,850.00`) on a violet gradient surface with `+18.4%` monthly savings rate badge and offline storage indicator.
* Monthly income (`PKR 155,000.00`) and monthly expense (`PKR 41,150.00`) side-by-side metric cards.
* Remaining monthly budget progress card (`PKR 17,850.00 left of PKR 59,000.00 cap`, 70% used).
* Category spending breakdown preview (Bills 30.1%, Food 27.3%, Shopping 22.4%, Transport 11.7%).
* Recent transactions preview with category icons, relative timestamps, notes, amounts, and a "View All" link to History.

### Screen B: Add Transaction Screen (`AddTransactionScreen`)
* Income / Expense segmented toggle with animated switching and distinct color accents.
* Amount input card with `PKR` prefix and preset amount chips (`+500`, `+1,000`, `+2,500`, `+5,000`, `+10,000`).
* Dynamic category selector chips filtered by transaction type (Income vs Expense).
* Date picker with formatted date display (defaults to Today).
* Optional note field with clear placeholder.
* Validation-ready form structure with clear dialog confirmation explaining Day 2 persistence readiness.
* Form reset action.

### Screen C: Transaction History Screen (`HistoryScreen`)
* Chronological transaction timeline displaying newest transactions first.
* Visual distinction: Income with emerald green badge and `+`; Expense with coral badge and `-`.
* Category icons with soft colored background containers.
* Interactive month filter pills ("All Months", "Nov 2026", "Oct 2026", "Sep 2026").
* Interactive category & type filter chips ("All Types", "Expenses", "Income", plus individual category chips).
* Real-time summary strip displaying active transaction count, filtered income sum, and filtered expense sum.
* Empty state with reset filters button when a filter combination yields zero matches.

### Screen D: Budgets Screen (`BudgetsScreen`)
* Overall monthly budget pool card (`PKR 17,850.00 remaining`, `PKR 41,150.00 spent of PKR 59,000.00 cap`, 70% allocated).
* Over-budget visual alert highlighting when an allocation is exceeded (Shopping & Gear at 115% limit).
* Category budget cards with category icon, spent vs limit, remaining quota, and dynamic progress bar (purple for normal, amber for $\ge 80\%$, coral red for over-budget).
* Educational card explaining category budget logic and previewing custom budget creation arriving in Day 3.
* Modal preview for "Add Budget" action.

### Screen E: Settings & Diagnostics Screen (`SettingsScreen`)
* User profile summary with tier badge.
* Currency and precision configuration details.
* Live SQLite health check: "Test DB" button executing a live query against SQLite, confirming database connection, schema v1.0, and 11 pre-seeded categories.

---

## 5. Flutter Project Architecture & Folder Structure

```
spend_wise/
├── lib/
│   ├── main.dart                                # Entry point & SQLite bootstrap
│   ├── app/
│   │   ├── app.dart                             # Root MaterialApp configuration
│   │   ├── navigation/
│   │   │   └── app_scaffold.dart                # Bottom navigation bar & IndexedStack
│   │   └── theme/
│   │       ├── app_colors.dart                  # Brand colors & gradients
│   │       ├── app_typography.dart              # Standardized type scale
│   │       └── app_theme.dart                   # Material 3 ThemeData
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_dimensions.dart              # Spacing & border radiuses
│   │   │   └── app_strings.dart                 # Text strings & currency metadata
│   │   ├── database/
│   │   │   ├── database_constants.dart          # Table names, column keys & SQL DDL
│   │   │   ├── app_database.dart                # SQLite singleton, FFI runner & seeds
│   │   │   └── database_service.dart            # Repository helper queries
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart          # Minor units converter & PKR formatter
│   │   │   └── date_formatter.dart              # Relative and standard date formatting
│   │   └── widgets/
│   │       ├── custom_card.dart                 # Reusable fintech card
│   │       ├── metric_card.dart                 # Income/Expense metric card
│   │       ├── preview_banner.dart              # Day 1 sample data banner
│   │       ├── primary_button.dart              # Gradient brand action button
│   │       ├── section_header.dart              # Section header with action link
│   │       └── empty_state_view.dart            # Illustrated empty-state widget
│   ├── models/
│   │   ├── transaction_model.dart               # Minor-unit integer transaction model
│   │   ├── category_model.dart                  # Category model with icon/color mapping
│   │   └── budget_model.dart                    # Category budget model (Day 3 foundation)
│   ├── data/
│   │   └── sample_data.dart                     # Isolated sample presentation fixtures
│   └── features/
│       ├── dashboard/                           # Home dashboard screen & widgets
│       ├── transactions/                        # Add transaction screen & form
│       ├── history/                             # History timeline & filter bar
│       ├── budgets/                             # Budget manager & category cards
│       └── settings/                            # Settings & SQLite health check
└── test/
    ├── widget_test.dart                         # Navigation & model unit tests
    └── database_test.dart                       # SQLite schema & foreign key unit tests
```

---

## 6. Transaction & Category Data Models

### Fintech Minor-Units Standard
All financial amounts are stored as **integers in minor currency units (paisas)**:
* $1\text{ PKR} = 100\text{ Paisas}$
* `PKR 2,500.00` is stored as `250000`
* Eliminates binary floating-point rounding errors.
* Models provide `amountInMajorUnits` and `fromMajorUnits(...)` helper constructors.

### Models Implemented
1. **`TransactionModel`** (`lib/models/transaction_model.dart`):
   * `id` (`String`): Unique identifier.
   * `type` (`TransactionType`): Enum (`income` or `expense`).
   * `amount` (`int`): Stored strictly in minor units (paisas).
   * `date` (`DateTime`): Transaction timestamp.
   * `categoryId` (`String`): Foreign key referencing a category.
   * `note` (`String?`): Optional description.
   * `toMap()`, `fromMap()`, `copyWith()`, `amountInMajorUnits`, `signedFormattedAmount`.

2. **`CategoryModel`** (`lib/models/category_model.dart`):
   * `id` (`String`): Category ID (e.g. `cat_food`, `cat_salary`).
   * `name` (`String`): User-facing title.
   * `type` (`TransactionType`): `income` or `expense`.
   * `iconName` (`String`): Identifier mapping to Material Icons (`Icons.restaurant_rounded`, `Icons.work_rounded`, etc.).
   * `colorValue` (`int`): Hex integer color code (e.g. `0xFF10B981`).
   * `isDefault` (`bool`): Identifies pre-seeded system categories.

3. **`BudgetModel`** (`lib/models/budget_model.dart`):
   * `id`, `categoryId`, `limitAmount` (in minor units), `spentAmount`, `monthYear`.
   * Helpers: `progressRatio`, `percentage`, `isOverBudget`, `remainingAmount`, `overBudgetAmount`.

---

## 7. SQLite Database Setup & Schema

Implemented in `AppDatabase` (`lib/core/database/app_database.dart`):
* **Database Name:** `spend_wise.db` (Version 1)
* **Tables:**
  * `categories`: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `type TEXT NOT NULL`, `icon_name TEXT NOT NULL`, `color_value INTEGER NOT NULL`, `is_default INTEGER NOT NULL DEFAULT 1`
  * `transactions`: `id TEXT PRIMARY KEY`, `type TEXT NOT NULL`, `amount INTEGER NOT NULL`, `date TEXT NOT NULL`, `category_id TEXT NOT NULL`, `note TEXT`, `FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE`
  * `budgets`: `id TEXT PRIMARY KEY`, `category_id TEXT NOT NULL`, `limit_amount INTEGER NOT NULL`, `month_year TEXT NOT NULL`, `FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE`
* **Indexes:**
  * `idx_transactions_date`: Index on `transactions(date DESC)`
  * `idx_transactions_category`: Index on `transactions(category_id)`
* **Foreign Key Constraints:** Enabled on every SQLite connection via `PRAGMA foreign_keys = ON;`.
* **Pre-seeded Categories:** 11 default categories inserted within a single batch transaction on database creation.
* **Desktop / Test Compatibility:** Automatically initializes `sqflite_common_ffi` on Windows/Desktop/Test runners.

---

## 8. Packages & Technologies Used

* **Flutter SDK:** 3.47.1 (Channel stable)
* **Dart SDK:** 3.13.1
* **UI Design Framework:** Material 3
* **`sqflite` (2.4.5):** Core local SQLite database engine for Android & iOS.
* **`sqflite_common_ffi` (2.4.5):** SQLite FFI engine supporting Windows desktop and unit tests.
* **`path` (1.9.1):** Cross-platform database file path joining.
* **`intl` (0.20.3):** Currency and date formatting.
* **`flutter_test`:** Automated widget and unit testing framework.

---

## 9. Working Navigation Explanation

Implemented in `AppScaffold` (`lib/app/navigation/app_scaffold.dart`):
* **5 Working Tabs:**
  1. `Home` (Index 0) $\rightarrow$ `DashboardScreen`
  2. `History` (Index 1) $\rightarrow$ `HistoryScreen`
  3. `Add` (Index 2) $\rightarrow$ `AddTransactionScreen` (Central highlighted gradient button)
  4. `Budgets` (Index 3) $\rightarrow$ `BudgetsScreen`
  5. `Settings` (Index 4) $\rightarrow$ `SettingsScreen`
* **Persistent Tab State:** Powered by `IndexedStack` so scroll positions and active form inputs are not lost when switching tabs.
* **Cross-Screen Deep Navigation:**
  * Dashboard "View All" link $\rightarrow$ switches to History tab.
  * Dashboard "Budgets" link $\rightarrow$ switches to Budgets tab.
  * Dashboard quick add $\rightarrow$ switches to Add Transaction tab.

---

## 10. Flutter Analyze & Test Results

### `flutter analyze`
```
Analyzing spend_wise...
No issues found! (ran in 5.3s)
```

### `flutter test`
```
00:00 +0: C:/Users/umair/Desktop/spend_wise/test/database_test.dart: SQLite Schema & CRUD Unit Tests: Verifies Categories & Transactions schema and constraints
00:00 +1: C:/Users/umair/Desktop/spend_wise/test/database_test.dart: SQLite Schema & CRUD Unit Tests: Enforces foreign key constraint between transactions & categories
00:00 +2: C:/Users/umair/Desktop/spend_wise/test/widget_test.dart: SpendWise App & Navigation Tests: App renders Dashboard and bottom navigation destinations
00:03 +3: C:/Users/umair/Desktop/spend_wise/test/widget_test.dart: Model & Minor Currency Unit Tests: Transaction Model minor currency units conversion
00:03 +4: C:/Users/umair/Desktop/spend_wise/test/widget_test.dart: Model & Minor Currency Unit Tests: Category Model serialization and icon resolution
00:03 +5: C:/Users/umair/Desktop/spend_wise/test/widget_test.dart: Model & Minor Currency Unit Tests: CurrencyFormatter parses input and formats PKR accurately
00:03 +6: All tests passed!
```

---

## 11. Challenges Encountered & Solutions

1. **Host Disk Space Exhaustion:**
   * *Issue:* The host machine had only 30 MB free on drive C:, causing `flutter test` and compiler commands to fail with OS Error 112.
   * *Solution:* Emptied the Recycle Bin and cleared stale temporary directories using PowerShell, recovering over 2.5 GB of free space and restoring full compilation capability.
2. **Material 3 `CardTheme` vs `CardThemeData` Deprecation:**
   * *Issue:* In Flutter 3.47+, assigning `CardTheme` directly to `ThemeData.cardTheme` triggers an `argument_type_not_assignable` lint.
   * *Solution:* Updated `AppTheme` to use `CardThemeData`, satisfying modern Material 3 type constraints.
3. **SQLite Execution Across Mobile and Desktop/Tests:**
   * *Issue:* `sqflite` mobile plugin requires native platform channels, which fail during standard Dart unit tests and desktop builds.
   * *Solution:* Integrated `sqflite_common_ffi` and added platform checking in `AppDatabase`, ensuring automated tests and desktop execution run smoothly without emulators.

---

## 12. What I Learned Today

* **Fintech Engineering Precision:** The rationale and necessity behind the minor currency units standard (storing paisas as integers) to eliminate IEEE 754 floating-point errors in financial calculations.
* **Production-Grade SQLite Patterns:** How to implement foreign key cascading, create indexing strategies, and batch pre-seed default categories on database creation.
* **Material 3 Design Systems:** Building a consistent design system with unified typography, color semantics, and responsive spacing.
* **State Preservation via `IndexedStack`:** Managing persistent screen states across multi-tab applications without rebuilding widget trees unnecessarily.

---

## 13. Remaining Work Planned for Tuesday (Day 2)

* **Functional Transaction CRUD:** Connect `AddTransactionScreen` to write directly to SQLite via `DatabaseService.insertTransaction()`.
* **Live History Timeline:** Replace sample presentation data with a reactive stream or FutureBuilder fetching real saved transactions from SQLite.
* **Transaction Management:** Implement swipe-to-delete and detail/edit dialogs for recorded expenses and income.
* **Dashboard Database Binding:** Bind the Total Balance, Monthly Income, and Monthly Expenses cards to real aggregated SQLite queries.

