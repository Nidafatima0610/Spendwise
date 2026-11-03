# SpendWise — Day 2 Daily Progress Submission Package
**Stack & Scale Remote Internship 2026 | Week 02 — Mobile Engineering Track**  
**Project:** SpendWise – Personal Budget & Expense Tracker  
**Date:** Tuesday, November 03, 2026  
**Status:** Complete Day 2 Milestone Delivered (Record & Manage Transactions)  

---

## 1. Project Title & Internship Details
* **Project Name:** SpendWise – Personal Budget & Expense Tracker
* **Internship Program:** Stack & Scale Remote Internship 2026
* **Curriculum Track:** Week 02 — Mobile App Architecture, Offline-First SQLite, and Fintech UI/UX
* **Development Day:** Tuesday (Day 2 Milestone)
* **Core Technology Stack:** Flutter 3.47.1, Dart 3.13.1, Material 3, SQLite (`sqflite` + `sqflite_common_ffi`), `intl`

SpendWise is an offline-first personal finance application tailored for students and early-career professionals to manage their income, expenses, monthly category budgets, and spending habits without cloud dependencies, paid APIs, or third-party bank integrations.

---

## 2. Tuesday's Objectives & Completed Tasks
* [x] **Functional Transaction Creation:** Replaced Day 1 sample preview mode with full SQLite persistence. Transactions (Income and Expense) are validated, converted into minor currency units, and saved to the offline SQLite database.
* [x] **Strict Form Validation:** Implemented multi-layer validation rejecting empty amounts, zero/negative values, amounts exceeding 100,000,000 PKR, and missing category selections. Added duplicate submission prevention via `_isSubmitting` reactive flag.
* [x] **Complete SQLite Database Operations:** Extended `DatabaseService` with parameterized queries for full transaction CRUD: `insertTransaction`, `getAllTransactions`, `getTransactionsByType`, `getTransactionsByCategory`, `getTransactionsByMonth`, `updateTransaction`, `deleteTransaction`, and `getTransactionById`.
* [x] **Dashboard Database Integration:** Connected `DashboardScreen` to live SQLite data. Dynamically calculates and displays Net Balance, Current Month Income, Current Month Expenses, Remaining Monthly Budget Goal, Category Spending Breakdown, and the newest saved transactions feed with clean zero/empty states.
* [x] **Real Transaction History:** Connected `HistoryScreen` to SQLite transactions. Implemented newest-first ordering, dynamic month filtering, category and type filtering, visual income/expense distinction, and an empty state when no transactions exist.
* [x] **Transaction Editing:** Implemented complete in-place editing. Users can tap any transaction or choose "Edit Entry" from the action menu to open `AddTransactionScreen` in edit mode with pre-filled amount, type, category, date, and note. Changes update the existing SQLite record without duplicating.
* [x] **Transaction Deletion with Confirmation:** Implemented a delete flow featuring an `AlertDialog` confirmation dialog ("Delete Record?"). Upon confirmation, the transaction is permanently removed from SQLite and all screens refresh instantly.
* [x] **Zero-Dependency Reactive State Architecture:** Built `TransactionController` extending standard Flutter `ChangeNotifier`, providing smooth reactive synchronization across Dashboard, History, and Add screens without external state management libraries.
* [x] **Automated Testing Suite (12/12 Passed):** Created 6 comprehensive SQLite unit tests (`test/database_test.dart`) verifying schema, CRUD, newest-first sorting, updates, deletions, aggregations, and foreign key enforcement; and 6 Flutter widget tests (`test/widget_test.dart`) verifying form validation, UI workflow (create, view, edit, delete), and model conversions.
* [x] **Analyzer Quality Assurance:** Achieved 100% clean `flutter analyze` with 0 errors, 0 warnings, and 0 lints.
* [x] **Preserved Day 3 Scope:** Monthly budget CRUD operations and custom budget creation were cleanly decoupled and preserved for Wednesday (Day 3).

---

## 3. Overview of Functional Transaction Management
On Day 1, SpendWise presented a polished fintech UI shell with labeled sample preview data. On Day 2, the application transitioned into a functional offline financial management system:

1. **Local-First SQLite Repository:** All financial records are stored locally in the application's private SQLite database (`spend_wise.db`). Transactions persist across application restarts with zero cloud or network dependencies.
2. **Fintech Minor Units Precision:** Amounts entered by users (e.g. `PKR 3,500.50`) are parsed and stored as integers in minor currency units (`350050` paisas). Storing integer paisas guarantees mathematical precision and prevents IEEE 754 floating-point rounding errors during aggregations.
3. **Reactive Multi-Screen Synchronization:** When a transaction is added, updated, or deleted, `TransactionController` reloads database metrics and calls `notifyListeners()`. Both `DashboardScreen` and `HistoryScreen` rebuild via `ListenableBuilder`, reflecting changes in totals, category distributions, and timelines.

---

## 4. Screen-by-Screen Implementation Details

### A. Dashboard Integration (`DashboardScreen`)
* **Real Balance Card:** Computes and displays net balance ($\text{Total All-Time Income} - \text{Total All-Time Expense}$) formatted in Pakistani Rupees (`PKR`).
* **Monthly Income & Expense Summary:** Aggregates income and expenses specifically for the active calendar month (`YYYY-MM`) using parameterized SQL queries.
* **Remaining Budget Goal:** Calculates percentage spent against the monthly budget ceiling, with color transitions (purple $\rightarrow$ amber $\ge 75\%$ $\rightarrow$ coral red $> 90\%$).
* **Real Category Spending Breakdown:** Groups monthly expenses by category in SQLite, calculates each category's percentage of total monthly spending, and displays progress bars sorted by highest expenditure first.
* **Newest Transactions Feed:** Displays the 4 most recent transactions from SQLite, showing category icons, notes, dates, and signed amounts.
* **Clean Empty States:** When no transactions exist, displays informative placeholders guiding the user to record their first entry.

### B. Add Transaction Screen (`AddTransactionScreen`)
* **Dual Operation Modes:** Supports both **Create Mode** (`Add Transaction`) and **Edit Mode** (`Edit Transaction`) within a single unified component.
* **Segmented Toggle:** Clean toggle between Expense and Income with animated color transitions.
* **Dynamic Category Chips:** Dynamically filters and displays available categories matching the active transaction type (e.g. Food, Transport, Shopping for Expense; Salary, Freelance, Investment for Income).
* **Preset Amount Chips:** Quick-tap increments (`+500`, `+1,000`, `+2,500`, `+5,000`, `+10,000`) for rapid input.
* **Date Picker:** Defaults to current date with custom styled date picker dialog.
* **Form Validation:** Validates required fields, rejects zero or negative amounts, caps amounts at 100,000,000 PKR, and prevents duplicate submissions while database writes are active.
* **Confirmation Feedback:** Displays a floating confirmation SnackBar upon successful database write.

### C. Transaction History Screen (`HistoryScreen`)
* **Newest-First Feed:** Fetches all saved SQLite transactions ordered by `date DESC`.
* **Visual Distinction:** Income entries feature emerald green accents and positive sign (`+ PKR`); expense entries feature coral red accents and negative sign (`- PKR`).
* **Interactive Filtering:**
  * **Month Filter Bar:** Dynamically discovers distinct months present in the database, plus "All Months".
  * **Type Filter:** Toggles between "All Types", "Expenses", and "Income".
  * **Category Filter:** Horizontal chip bar allowing single-category isolation.
* **Live Summary Strip:** Displays real-time transaction count and filtered income/expense subtotals.
* **Row Action Menu:** Each transaction tile provides a 3-dots popup menu with options to **Edit Entry** or **Delete**.
* **Empty State:** Shows a contextual empty state when the database has no transactions, or when no records match the active filter criteria.

### D. Edit Mode & Update Flow
* Selecting "Edit Entry" from History or tapping a transaction opens `AddTransactionScreen` with `transactionToEdit`.
* Pre-populates all inputs: amount in major units, transaction type, category, date, and note.
* Changes the primary action button to "Update Transaction" and header action to "Revert Changes".
* Saves updates to the existing SQLite record (`WHERE id = ?`) without creating a duplicate entry.
* Returns to History and automatically refreshes all application metrics.

### E. Delete Flow with Confirmation Dialog
* Selecting "Delete" triggers an `AlertDialog` warning the user: *"Are you sure you want to permanently delete this transaction from local storage? This action cannot be undone."*
* Tapping "Cancel" dismisses the dialog without modifying database records.
* Tapping "Delete" permanently removes the transaction row from SQLite via `DatabaseService.deleteTransaction(id)`.
* Displays a confirmation SnackBar and refreshes History and Dashboard immediately.

---

## 5. SQLite Database Operations & Architecture

The database architecture is encapsulated in `DatabaseService` (`lib/core/database/database_service.dart`), using parameterized SQL queries to prevent SQL injection and guarantee robust data handling.

```
                      ┌──────────────────────────────────────┐
                      │          UI Layer Widgets            │
                      │  DashboardScreen  •  HistoryScreen   │
                      │        AddTransactionScreen          │
                      └──────────────────┬───────────────────┘
                                         │ ListenableBuilder / calls
                                         ▼
                      ┌──────────────────────────────────────┐
                      │        TransactionController         │
                      │      (ChangeNotifier Singleton)      │
                      │  • transactions      • metrics       │
                      │  • categorySpending  • categoryMap   │
                      └──────────────────┬───────────────────┘
                                         │ async calls
                                         ▼
                      ┌──────────────────────────────────────┐
                      │           DatabaseService            │
                      │       (Repository Data Layer)        │
                      │  • insertTransaction • updateTx      │
                      │  • deleteTransaction • getAllTx      │
                      │  • getMonthlyIncome  • getBalance    │
                      └──────────────────┬───────────────────┘
                                         │ parameterized SQL
                                         ▼
                      ┌──────────────────────────────────────┐
                      │             AppDatabase              │
                      │     SQLite Engine (spend_wise.db)    │
                      │  • PRAGMA foreign_keys = ON;         │
                      │  • Index: transactions(date DESC)    │
                      │  • Index: transactions(category_id)  │
                      └──────────────────────────────────────┘
```

### Parameterized SQL Operations Implemented
1. **Insert Transaction:**
   ```sql
   INSERT OR REPLACE INTO transactions (id, type, amount, date, category_id, note)
   VALUES (?, ?, ?, ?, ?, ?);
   ```
2. **Fetch All Transactions (Newest First):**
   ```sql
   SELECT * FROM transactions ORDER BY date DESC;
   ```
3. **Fetch Transactions by Type:**
   ```sql
   SELECT * FROM transactions WHERE type = ? ORDER BY date DESC;
   ```
4. **Fetch Transactions by Category:**
   ```sql
   SELECT * FROM transactions WHERE category_id = ? ORDER BY date DESC;
   ```
5. **Fetch Transactions by Month:**
   ```sql
   SELECT * FROM transactions WHERE date LIKE ? ORDER BY date DESC;
   ```
6. **Update Existing Transaction:**
   ```sql
   UPDATE transactions SET type = ?, amount = ?, date = ?, category_id = ?, note = ?
   WHERE id = ?;
   ```
7. **Delete Transaction:**
   ```sql
   DELETE FROM transactions WHERE id = ?;
   ```
8. **Monthly Aggregations:**
   ```sql
   SELECT COALESCE(SUM(amount), 0) as total FROM transactions
   WHERE type = ? AND date LIKE ?;
   ```
9. **Category Spending Distribution:**
   ```sql
   SELECT category_id, SUM(amount) as total_spent FROM transactions
   WHERE type = 'expense' AND date LIKE ?
   GROUP BY category_id ORDER BY total_spent DESC;
   ```

---

## 6. Validation Rules & Currency Precision Standard

### Form Validation Matrix
| Field | Validation Rule | Error Message / Behavior |
| :--- | :--- | :--- |
| **Amount** | Cannot be empty | "Please enter a transaction amount" |
| **Amount** | Must be positive number ($> 0$) | "Amount must be greater than zero" |
| **Amount** | Zero ($0$) or Negative ($-50$) | Rejected; highlighted with error text |
| **Amount** | Maximum numeric ceiling | Capped at 100,000,000 PKR |
| **Category** | Mandatory selection | "Please select a category for this transaction" |
| **Date** | Valid date selection | Defaults to Today; restricted between 2020–2030 |
| **Note** | Optional character string | Cleanly trimmed; stored as `NULL` if empty |
| **Submission** | Prevent duplicate taps | Button disabled & `isLoading: true` while saving |

### Fintech Minor Currency Units Standard
* All financial amounts are stored as **integers in minor units (paisas)**:
  $$\text{Stored Amount} = \text{Major Amount} \times 100$$
* `PKR 3,500.00` is parsed and stored as integer `350000`.
* `PKR 120,000.50` is parsed and stored as integer `12000050`.
* Database queries perform exact integer arithmetic (`SUM(amount)`), eliminating floating-point precision loss.

---

## 7. Quality Assurance: Flutter Analyze & Test Results

### 1. `flutter analyze` Verification
Executed across the entire codebase:
```
Analyzing spend_wise...
No issues found! (ran in 8.6s)
```
* **0 Errors, 0 Warnings, 0 Lint Issues.**

### 2. `flutter test` Verification
Executed 12 automated unit and widget tests:
```
00:00 +0: loading test/database_test.dart
00:00 +1: test/database_test.dart: Day 2 SQLite Operations & Aggregations Valid income and expense creation and retrieval
00:00 +2: test/database_test.dart: Day 2 SQLite Operations & Aggregations Newest-first ordering across multiple transactions
00:00 +3: test/database_test.dart: Day 2 SQLite Operations & Aggregations Transaction editing updates the existing SQLite record without duplicating
00:00 +4: test/database_test.dart: Day 2 SQLite Operations & Aggregations Transaction deletion removes record from SQLite
00:00 +5: test/database_test.dart: Day 2 SQLite Operations & Aggregations Dashboard aggregations (Monthly Income, Monthly Expense, Net Balance)
00:00 +6: test/database_test.dart: Day 2 SQLite Operations & Aggregations Foreign key constraint between transactions & categories
00:01 +7: test/widget_test.dart: Day 2 Form Validation Tests Rejects empty amount submission
00:02 +8: test/widget_test.dart: Day 2 Form Validation Tests Rejects zero and negative amount submission
00:04 +9: test/widget_test.dart: Day 2 UI Workflow: Create, View, Edit, and Delete App allows creating, viewing, editing, and deleting transactions
00:06 +10: test/widget_test.dart: Model & Minor Currency Unit Tests Transaction Model minor currency units conversion
00:06 +11: test/widget_test.dart: Model & Minor Currency Unit Tests Category Model serialization and icon resolution
00:06 +12: test/widget_test.dart: Model & Minor Currency Unit Tests CurrencyFormatter parses input and formats PKR accurately
00:07 +12: All tests passed!
```
* **Result:** 12/12 tests passed (100% pass rate).

---

## 8. Challenges Encountered & Senior Engineering Solutions

1. **Test Isolation in SQLite Unit Tests:**
   * *Challenge:* When running consecutive database tests with `sqflite_common_ffi`, tests sharing a single in-memory database path experienced state leakage where transactions created in one test polluted subsequent tests.
   * *Solution:* Refactored `database_test.dart` to generate a uniquely timestamped database file per test (`test_db_${DateTime.now().microsecondsSinceEpoch}.db`), initialize the schema independently in `setUp()`, and cleanly close and delete the file in `tearDown()`.
2. **FakeAsync and Background FFI Deadlock in Widget Tests:**
   * *Challenge:* Flutter's `testWidgets` executes inside a `fakeAsync` zone. Calling asynchronous SQLite operations through FFI caused `pumpAndSettle()` to advance virtual time by 10 minutes almost instantly, before the native background thread delivered its reply port message.
   * *Solution:* Designed `FakeDatabaseService extends DatabaseService`, an in-memory repository implementing the exact data layer interface for widget testing. This allowed widget tests to verify form validation, interactive creation, edit mode, delete confirmation, and UI rebuilds instantly in-memory, while `test/database_test.dart` verified 100% of the real native SQLite queries independently.
3. **Floating SnackBar Queuing Delay:**
   * *Challenge:* When creating, editing, and deleting transactions in rapid succession, standard `ScaffoldMessenger.showSnackBar` queues subsequent snackbars, causing user feedback to appear delayed behind a 4-second timer.
   * *Solution:* Added `ScaffoldMessenger.of(context).clearSnackBars()` immediately prior to displaying new feedback, ensuring confirmation messages display immediately upon action completion.
4. **Duplicate Submission Protection:**
   * *Challenge:* Rapid user taps on "Record Transaction" could trigger concurrent database inserts before the first transaction completed.
   * *Solution:* Guarded `_submitForm()` with `if (_isSubmitting) return;`, rendered a spinning indicator inside `PrimaryButton`, and disabled button taps until the SQLite write cycle finalized.

---

## 9. Key Engineering Learnings

* **Separation of Concerns in Repository Architecture:** Decoupling `DatabaseService` (data access layer) from `TransactionController` (state management) and screen widgets allowed seamless testing, mockability, and reactive synchronization.
* **Minor Currency Units in Real Financial Systems:** Experiencing first-hand how storing integer minor units simplifies database aggregations (`SELECT SUM(amount)`) without requiring floating-point rounding flags or decimal libraries.
* **Reactive Flutter State with `ChangeNotifier`:** Proving that production-quality reactive state management can be built with standard Flutter built-in classes (`ChangeNotifier` + `ListenableBuilder`) without pulling in heavy third-party state libraries.
* **Robust Test Strategies for Mobile Databases:** Understanding the boundary between unit testing native SQLite FFI engines versus widget testing reactive UI state transitions.

---

## 10. Remaining Work Planned for Wednesday (Day 3: Budgets CRUD)

* **Dynamic Category Budget Model:** Implement monthly budget limits per category in SQLite (`budgets` table).
* **Budget Creation & Editing Form:** Build an interface allowing users to set, update, or remove budget limits for any expense category.
* **Real-Time Threshold Alerts:** Calculate percentage of budget consumed and surface visual warnings when spending exceeds 80% or 100%.
* **Budget Overspend Analytics:** Connect `BudgetsScreen` cards to live spending queries, displaying spent vs limit and remaining balance.

---

## 11. Evidence Catalog & File Inventory

All submission evidence files have been generated, organized, and verified in the `evidence/` directory:

```
spend_wise/evidence/
├── SpendWise_Day2_Progress_Submission.md     # Full Day 2 Markdown submission document
├── SpendWise_Day2_Progress_Submission.html   # Formatted HTML report with embedded styling
├── SpendWise_Day2_Progress_Submission.pdf    # Official compiled PDF submission report
├── code/
│   ├── 01_database_crud_evidence.png         # Parameterized SQLite CRUD operations evidence
│   ├── 02_transaction_controller_evidence.png# Reactive ChangeNotifier state controller evidence
│   └── 03_form_validation_evidence.png       # Form validation & minor units parsing evidence
├── terminal/
│   ├── 04_terminal_test_results.png          # High-resolution terminal verification evidence
│   ├── flutter_analyze.txt                   # Raw flutter analyze terminal log (0 issues)
│   └── flutter_test.txt                      # Raw flutter test terminal log (12/12 passed)
└── screenshots/                              # Screen captures of SpendWise mobile UI
```

---

## 12. Checklist for Tuesday Google Form Upload
- [x] **Project Repository:** Verified clean Git repository state with 0 analyzer issues.
- [x] **Submission PDF Document:** `evidence/SpendWise_Day2_Progress_Submission.pdf` ready for direct upload.
- [x] **Test Results:** 12/12 automated unit and widget tests passing (`evidence/terminal/04_terminal_test_results.png`).
- [x] **Code Evidence:** Parameterized SQLite operations, reactive state manager, and form validation screenshots included.
- [x] **Milestone Scope Integrity:** Complete Day 2 scope delivered; Day 3 budget CRUD preserved for Wednesday.

