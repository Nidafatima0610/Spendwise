const fs = require('fs');
const path = require('path');
const docx = require('./.docx_tool/node_modules/docx');

const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  ImageRun,
  Header,
  Footer,
  PageNumber,
  PageBreak,
  AlignmentType,
  BorderStyle,
  WidthType,
  ShadingType,
  VerticalAlign,
  HeadingLevel,
} = docx;

// Color Palette Tokens (SpendWise Signature Purple/Violet Theme)
const COLOR_PRIMARY = '6536C7';      // Deep Violet / Purple
const COLOR_PRIMARY_LIGHT = '7E4EE0';// Violet Light
const COLOR_SURFACE = 'F6F4FD';      // Lavender Surface
const COLOR_SURFACE_LIGHT = 'FDFBFE';// Off-white
const COLOR_TEXT = '1E1B2E';         // Charcoal Primary Text
const COLOR_MUTED = '6B7280';        // Muted Slate Text
const COLOR_BORDER = 'D8D0F5';       // Subtle Violet Border
const COLOR_EMERALD = '10B981';      // Income Green
const COLOR_ROSE = 'EF4444';         // Expense Red
const COLOR_AMBER = 'F59E0B';        // Warning Amber
const COLOR_WHITE = 'FFFFFF';

// Helper to safely load image as ImageRun with keepWithNext to avoid separating from caption
function createImage(relPath, width, height) {
  const fullPath = path.resolve(relPath);
  if (!fs.existsSync(fullPath)) {
    console.warn('Warning: Image not found at', fullPath);
    return new Paragraph({
      alignment: AlignmentType.CENTER,
      keepWithNext: true,
      keepLines: true,
      children: [
        new TextRun({
          text: `[Image Missing: ${path.basename(relPath)}]`,
          italics: true,
          color: COLOR_ROSE,
          size: 20,
        }),
      ],
    });
  }
  const buffer = fs.readFileSync(fullPath);
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 60, after: 30 },
    keepWithNext: true,
    keepLines: true,
    children: [
      new ImageRun({
        data: buffer,
        transformation: {
          width: width,
          height: height,
        },
      }),
    ],
  });
}

// Helper for image caption (keepLines to prevent splitting across pages)
function createCaption(captionText) {
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 20, after: 80 },
    keepLines: true,
    children: [
      new TextRun({
        text: captionText,
        italics: true,
        size: 18, // 9pt
        color: COLOR_MUTED,
        font: 'Segoe UI',
      }),
    ],
  });
}

// Side-by-side two mobile screenshots table with cantSplit on row
function createSideBySideScreenshots(img1Path, cap1, img2Path, cap2) {
  // Mobile screenshot dimensions: 155 x 345 (9:20 aspect ratio)
  const img1 = createImage(img1Path, 155, 345);
  const cap1P = createCaption(cap1);
  const img2 = createImage(img2Path, 155, 345);
  const cap2P = createCaption(cap2);

  const noneBorder = { style: BorderStyle.NONE, size: 0, color: 'auto' };
  const borderObj = { top: noneBorder, bottom: noneBorder, left: noneBorder, right: noneBorder };

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: borderObj,
    alignment: AlignmentType.CENTER,
    rows: [
      new TableRow({
        cantSplit: true,
        children: [
          new TableCell({
            width: { size: 50, type: WidthType.PERCENTAGE },
            borders: borderObj,
            children: [img1, cap1P],
            verticalAlign: VerticalAlign.TOP,
          }),
          new TableCell({
            width: { size: 50, type: WidthType.PERCENTAGE },
            borders: borderObj,
            children: [img2, cap2P],
            verticalAlign: VerticalAlign.TOP,
          }),
        ],
      }),
    ],
  });
}

// Heading 1 helper with keepWithNext and keepLines
function createHeading1(title) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 240, after: 100 },
    keepWithNext: true,
    keepLines: true,
    children: [
      new TextRun({
        text: title,
        bold: true,
        size: 30, // 15pt
        color: COLOR_PRIMARY,
        font: 'Segoe UI Semibold',
      }),
    ],
  });
}

// Heading 2 helper with keepWithNext and keepLines
function createHeading2(title) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 180, after: 70 },
    keepWithNext: true,
    keepLines: true,
    children: [
      new TextRun({
        text: title,
        bold: true,
        size: 24, // 12pt
        color: COLOR_PRIMARY_LIGHT,
        font: 'Segoe UI Semibold',
      }),
    ],
  });
}

// Heading 3 helper with keepWithNext and keepLines
function createHeading3(title) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 140, after: 50 },
    keepWithNext: true,
    keepLines: true,
    children: [
      new TextRun({
        text: title,
        bold: true,
        size: 21, // 10.5pt
        color: COLOR_TEXT,
        font: 'Segoe UI Semibold',
      }),
    ],
  });
}

// Body paragraph helper with keepLines
function createParagraph(text, options = {}) {
  const { bold = false, italics = false, color = COLOR_TEXT, size = 20, spacingAfter = 80 } = options;
  return new Paragraph({
    spacing: { before: 0, after: spacingAfter, line: 250 },
    keepLines: true,
    children: [
      new TextRun({
        text: text,
        bold: bold,
        italics: italics,
        color: color,
        size: size,
        font: 'Segoe UI',
      }),
    ],
  });
}

// Bullet item helper with keepLines
function createBullet(text, boldPrefix = '') {
  return new Paragraph({
    bullet: { level: 0 },
    spacing: { before: 15, after: 35, line: 240 },
    keepLines: true,
    children: [
      ...(boldPrefix ? [new TextRun({ text: boldPrefix + ' ', bold: true, color: COLOR_PRIMARY, size: 20, font: 'Segoe UI Semibold' })] : []),
      new TextRun({ text: text, color: COLOR_TEXT, size: 20, font: 'Segoe UI' }),
    ],
  });
}

// Callout / Note card helper with cantSplit and keepLines
function createCallout(title, body, compact = false) {
  const borderSide = { style: BorderStyle.SINGLE, size: 20, color: COLOR_PRIMARY };
  const borderNone = { style: BorderStyle.NONE, size: 0, color: 'auto' };

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: {
      left: borderSide,
      top: borderNone,
      right: borderNone,
      bottom: borderNone,
    },
    rows: [
      new TableRow({
        cantSplit: true,
        children: [
          new TableCell({
            width: { size: 100, type: WidthType.PERCENTAGE },
            shading: { fill: COLOR_SURFACE, type: ShadingType.CLEAR },
            margins: compact
              ? { top: 50, bottom: 50, left: 120, right: 120 }
              : { top: 80, bottom: 80, left: 140, right: 140 },
            children: [
              new Paragraph({
                spacing: { before: 0, after: compact ? 25 : 40 },
                keepWithNext: true,
                keepLines: true,
                children: [
                  new TextRun({
                    text: title,
                    bold: true,
                    size: compact ? 19 : 20,
                    color: COLOR_PRIMARY,
                    font: 'Segoe UI Semibold',
                  }),
                ],
              }),
              new Paragraph({
                spacing: { before: 0, after: 0, line: 230 },
                keepLines: true,
                children: [
                  new TextRun({
                    text: body,
                    size: compact ? 18 : 19,
                    color: COLOR_TEXT,
                    font: 'Segoe UI',
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  });
}

// Styled Data Table helper with cantSplit on every row
function createDataTable(headers, rows, compact = false) {
  const borderThin = { style: BorderStyle.SINGLE, size: 4, color: COLOR_BORDER };
  const bordersAll = { top: borderThin, bottom: borderThin, left: borderThin, right: borderThin };

  const topPad = compact ? 35 : 70;
  const bottomPad = compact ? 35 : 70;
  const sidePad = compact ? 80 : 120;
  const fontSize = compact ? 18 : 19;

  const headerRow = new TableRow({
    cantSplit: true,
    children: headers.map(h => new TableCell({
      shading: { fill: COLOR_PRIMARY, type: ShadingType.CLEAR },
      borders: bordersAll,
      margins: { top: topPad, bottom: bottomPad, left: sidePad, right: sidePad },
      children: [
        new Paragraph({
          alignment: AlignmentType.LEFT,
          keepWithNext: true,
          keepLines: true,
          children: [
            new TextRun({
              text: h,
              bold: true,
              color: COLOR_WHITE,
              size: fontSize,
              font: 'Segoe UI Semibold',
            }),
          ],
        }),
      ],
    })),
  });

  const tableRows = [headerRow];

  rows.forEach((row, idx) => {
    const bg = idx % 2 === 0 ? COLOR_WHITE : COLOR_SURFACE;
    tableRows.push(
      new TableRow({
        cantSplit: true,
        children: row.map((cellText, cellIdx) => new TableCell({
          shading: { fill: bg, type: ShadingType.CLEAR },
          borders: bordersAll,
          margins: { top: topPad, bottom: bottomPad, left: sidePad, right: sidePad },
          children: [
            new Paragraph({
              alignment: AlignmentType.LEFT,
              spacing: { before: 0, after: 0, line: 220 },
              keepLines: true,
              children: [
                new TextRun({
                  text: cellText,
                  bold: cellIdx === 0,
                  color: cellIdx === 0 ? COLOR_PRIMARY : COLOR_TEXT,
                  size: fontSize,
                  font: 'Segoe UI',
                }),
              ],
            }),
          ],
        })),
      })
    );
  });

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: bordersAll,
    alignment: AlignmentType.CENTER,
    rows: tableRows,
  });
}

console.log('Building SpendWise Weekly Project Documentation...');

// Build Document Body
const docChildren = [
  // ==========================================
  // SECTION 1: COVER PAGE (GUARANTEED PAGE 1)
  // ==========================================
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    borders: {
      left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
      right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
      top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
      bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
    },
    rows: [
      new TableRow({
        cantSplit: true,
        children: [
          new TableCell({
            width: { size: 100, type: WidthType.PERCENTAGE },
            shading: { fill: COLOR_PRIMARY, type: ShadingType.CLEAR },
            margins: { top: 180, bottom: 180, left: 220, right: 220 },
            children: [
              new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { before: 0, after: 35 },
                keepWithNext: true,
                children: [
                  new TextRun({
                    text: 'STACK & SCALE REMOTE INTERNSHIP 2026',
                    bold: true,
                    size: 20,
                    color: 'E9D8FD',
                    font: 'Segoe UI Semibold',
                  }),
                ],
              }),
              new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { before: 0, after: 35 },
                keepWithNext: true,
                children: [
                  new TextRun({
                    text: 'WEEK 02 — COMPREHENSIVE PROJECT REPORT',
                    bold: true,
                    size: 18,
                    color: 'D6BCFA',
                    font: 'Segoe UI Semibold',
                  }),
                ],
              }),
              new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { before: 60, after: 35 },
                keepWithNext: true,
                children: [
                  new TextRun({
                    text: 'SpendWise',
                    bold: true,
                    size: 48, // 24pt
                    color: COLOR_WHITE,
                    font: 'Segoe UI Black',
                  }),
                ],
              }),
              new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { before: 0, after: 60 },
                keepWithNext: true,
                children: [
                  new TextRun({
                    text: 'Personal Budget & Expense Tracker',
                    bold: true,
                    size: 22, // 11pt
                    color: 'F3EEFD',
                    font: 'Segoe UI Semibold',
                  }),
                ],
              }),
              new Paragraph({
                alignment: AlignmentType.CENTER,
                spacing: { before: 0, after: 0 },
                children: [
                  new TextRun({
                    text: 'Offline-First Financial Management Engine Built with Flutter, Dart & SQLite',
                    italics: true,
                    size: 18, // 9pt
                    color: 'E9D8FD',
                    font: 'Segoe UI',
                  }),
                ],
              }),
            ],
          }),
        ],
      }),
    ],
  }),

  new Paragraph({ spacing: { before: 70, after: 30 } }),

  // Metadata Table on Cover Page (Compact to ensure perfect single-page fit)
  createDataTable(
    ['Project Specification', 'Submission Metadata Details'],
    [
      ['Internship Cohort', 'Stack & Scale Remote Internship 2026 — Cohort Evaluation'],
      ['Project Title', 'SpendWise — Personal Budget & Expense Tracker'],
      ['Evaluation Milestone', 'Week 02 Final Deliverable (Days 1 to 5 Complete)'],
      ['Lead Developer', 'Nida Fatima'],
      ['Project Duration', '02 November 2026 – 06 November 2026'],
      ['Application Framework', 'Flutter 3.x / Dart 3.x (Material 3 Fintech Theme)'],
      ['Database Architecture', 'Offline-First Relational SQLite (sqflite / sqflite_common_ffi)'],
      ['State Management', 'Native Flutter ChangeNotifier (Zero External Dependency Bloat)'],
      ['Precision Currency', 'PKR Minor Units Standard (Integer Paisas / 1 PKR = 100 Paisa)'],
      ['Target Audience', 'Students, Early-Career Professionals & Freelance Developers'],
      ['Verification Status', '37 / 37 Automated Tests Passing • 0 Flutter Analyze Issues'],
    ],
    true // compact mode
  ),

  new Paragraph({ spacing: { before: 60, after: 20 } }),
  createCallout(
    'Formal Submission Certification',
    'This technical report constitutes the official Week 02 project documentation for SpendWise. All screenshots, architectural schemas, source code snippets, database structures, and automated test outputs presented herein are authentic artifacts generated from the live Flutter runtime and verified against the internship requirements.',
    true // compact mode
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 2: PROJECT INTRODUCTION (PAGES 2 & 3)
  // ==========================================
  createHeading1('Section 2: Project Introduction'),
  createParagraph(
    'SpendWise is a production-grade, offline-first personal budget and expense tracking application engineered to help students, recent graduates, and early-career software professionals master their daily spending and monthly cash flow. Personal financial discipline in the modern era is frequently hindered by complex, bloated cloud banking applications that require third-party financial logins, track user behaviors, or enforce paid monthly subscriptions. SpendWise was conceived to deliver a fast, completely private, and mathematically exact financial ledger that runs 100% locally on the user\'s physical device.'
  ),

  createHeading2('2.1 Core Problem Statement'),
  createParagraph(
    'Young adults transitioning into independent financial life encounter distinct challenges that generic budgeting tools fail to address adequately:'
  ),
  createBullet('Privacy Risks & Cloud Dependencies: Traditional financial trackers demand cloud credentials, email logins, or bank synchronization, exposing sensitive personal expenditures to commercial cloud databases.', '1. Privacy Overhead:'),
  createBullet('Floating-Point Accounting Drift: Many beginner financial apps rely on standard IEEE 754 double floating-point numbers, allowing micro-rounding errors to accumulate across transactions and cause balance discrepancies.', '2. Arithmetic Rounding:'),
  createBullet('Uncontrolled Overspending: Typical expense apps record transactions passively without providing proactive spending caps, resulting in end-of-month budget shortfalls.', '3. Reactive Tracking:'),
  createBullet('Complex UI Clutter: Enterprise banking software often overwhelms younger users with unnecessary stock portfolios, loan advertisements, and crypto widgets.', '4. Interface Overload:'),

  createHeading2('2.2 The SpendWise Offline-First Philosophy'),
  createParagraph(
    'SpendWise operates on an uncompromising offline-first architectural model. From the moment the application is installed, all transactional data, category allocations, and monthly budget limits are stored directly inside an embedded, native SQLite database on the client machine. The application requires zero internet connectivity, transmits zero tracking telemetry, and provides near-instantaneous query execution with zero network latency.'
  ),

  createCallout(
    'Offline-First Architectural Guarantee',
    'SpendWise maintains complete functionality in air-gapped environments, on mobile devices in airplane mode, and across offline desktop sessions. Transactions logged offline persist permanently across application terminations, device reboots, and operating system updates without requiring synchronization servers.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 3: 2.3 and Core Value Matrix
  createHeading2('2.3 How SpendWise Empowers User Financial Health'),
  createParagraph(
    'The application provides an intuitive five-stage financial management loop engineered to foster proactive spending discipline:'
  ),
  createBullet('Real-Time Balance Visualization: The Executive Dashboard aggregates lifetime income and expenses into an instant net balance hero card formatted in Pakistani Rupees (PKR).', '1. Holistic Cockpit:'),
  createBullet('Dual-Type Transaction Logging: Users log expenses and income with dynamic category chips, custom notes, date picker selection, and immediate minor-unit conversion.', '2. Transaction CRUD:'),
  createBullet('Proactive Monthly Budgeting: Category spending caps track expenditures in real-time and provide automatic 80% warning triggers and 100% over-budget alerts.', '3. Spending Caps:'),
  createBullet('Historical Ledger Filtering: The History screen provides multi-axis navigation by month and category chips to isolate spending patterns.', '4. Multi-Axis Filtering:'),
  createBullet('Proportional Category Analytics: Visual horizontal progress bars display exact percentage shares of monthly expenditures sorted by highest cost first.', '5. Visual Breakdown:'),

  new Paragraph({ spacing: { before: 120, after: 40 } }),
  createHeading3('Core Value Proposition Summary Matrix'),
  createDataTable(
    ['Fintech Dimension', 'SpendWise Offline Engine', 'Standard Cloud Budgeting Apps'],
    [
      ['Data Privacy & Storage', '100% Local SQLite on client device', 'Centralized third-party cloud database'],
      ['Network Dependency', 'Zero internet connectivity required', 'Mandatory online login & API syncing'],
      ['Monetary Arithmetic', 'Exact integer minor units (PKR Paisas)', 'Approximated double floating-point numbers'],
      ['Telemetry & Ads', 'Zero trackers, zero ads, zero fees', 'Monetized data sharing & commercial ads'],
      ['Response Latency', 'Sub-millisecond native disk access', 'Variable latency bounded by network speed'],
    ]
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 3: TECHNOLOGIES USED (PAGES 4 & 5)
  // ==========================================
  createHeading1('Section 3: Technologies Used'),
  createParagraph(
    'SpendWise is constructed upon an enterprise-ready, cross-platform technical stack selected for performance, reliability, and long-term maintainability. The entire tech stack adheres strictly to the Stack & Scale Week 02 specifications, avoiding unvetted third-party state managers or unnecessary cloud dependencies.'
  ),

  createHeading2('3.1 Technology Stack Matrix'),
  createDataTable(
    ['Technology / Library', 'Version', 'Role in SpendWise', 'Engineering Justification'],
    [
      ['Flutter SDK', '^3.13.1 (Dart 3.x)', 'UI Framework & Engine', 'Provides high-DPI rendering, native widgets, and declarative reactive layout across platforms.'],
      ['Dart Language', '^3.1.0', 'Core Application Code', 'Enforces strict null-safety, async/await concurrency, and object-oriented architectural patterns.'],
      ['Material 3', 'M3 Design System', 'Fintech UI Identity', 'Modern rounded surfaces, elevation tokens, dynamic color roles, and accessible typography.'],
      ['sqflite', '^2.4.5', 'Mobile SQLite Engine', 'Provides native SQLite driver integration for iOS and Android with parameterized SQL queries.'],
      ['sqflite_common_ffi', '^2.4.5', 'Desktop/Test SQLite', 'Enables native C-level SQLite engine execution on Windows, macOS, Linux, and automated test runners.'],
      ['intl', '^0.20.3', 'Localization & Currency', 'Standardized parsing and formatting for Pakistani Rupee (PKR) and ISO-8601 calendar dates.'],
      ['path', '^1.9.1', 'Path Resolution', 'Cross-platform file-system directory manipulation for SQLite database file storage.'],
      ['ChangeNotifier', 'Flutter Built-in', 'State Management', 'Lightweight, predictable, native reactive state without the architectural overhead of third-party packages.'],
    ]
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 5: 3.2 Minor Currency Units Standard
  createHeading2('3.2 The Minor Currency Units Standard (PKR Paisas)'),
  createParagraph(
    'A cornerstone architectural decision in SpendWise is the strict adoption of integer minor currency units. In computer science, floating-point arithmetic (IEEE 754 standard) frequently produces precision decay due to binary fraction limitations. For example, evaluating 0.1 + 0.2 in standard floating-point yields 0.30000000000000004. In personal finance, accumulating fractional errors can corrupt account balances, break budget limit comparisons, and introduce discrepancies into audit ledgers.'
  ),

  createCallout(
    'Fintech Minor Units Architectural Standard',
    'Throughout the SpendWise data pipeline—including SQLite database schemas, Dart model properties, controller calculations, and test assertions—monetary amounts are stored strictly as 64-bit integers representing minor units (PKR Paisas). One Pakistani Rupee equals 100 Paisas (PKR 1.00 = 100 Paisa). Major currency values are derived exclusively at the presentation layer using the CurrencyFormatter utility.'
  ),

  new Paragraph({ spacing: { before: 100, after: 40 } }),
  createHeading3('Major-to-Minor Currency Conversion Matrix'),
  createDataTable(
    ['User Input (Major PKR)', 'Internal SQLite Stored Value', 'Formatted UI Representation', 'Conversion Logic Applied'],
    [
      ['PKR 2,500.00', '250000 (integer)', 'PKR 2,500.00', '2500.00 * 100 -> round to int'],
      ['PKR 185,000.50', '18500050 (integer)', 'PKR 185,000.50', '185000.50 * 100 -> round to int'],
      ['PKR 65,000.00', '6500000 (integer)', 'PKR 65,000.00', '65000.00 * 100 -> round to int'],
      ['PKR 51,000.00', '5100000 (integer)', 'PKR 51,000.00', '51000.00 * 100 -> round to int'],
      ['PKR 0.75', '75 (integer)', 'PKR 0.75', '0.75 * 100 -> round to int'],
    ]
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 4: SOURCE CODE SCREENSHOTS (8 PAGES: 6 TO 13)
  // Each figure is a self-contained Code Dossier on its own full page
  // Width: 460pt, Height: 230pt (fits within 480pt printable width)
  // ==========================================
  createHeading1('Section 4: Source Code Screenshots'),
  createParagraph(
    'This section presents genuine source code screenshots captured from the primary engineering files in the SpendWise codebase. Each figure illustrates a critical architectural subsystem, highlighting design patterns, database integration, validation logic, and reactive calculations.'
  ),

  // Figure 4.1 Dossier (Page 6)
  createHeading2('4.1 Transaction and Category Data Models'),
  createImage('evidence/code/01_models_evidence.png', 460, 230),
  createCaption('Figure 4.1: lib/models/transaction_model.dart & category_model.dart — Minor Currency Units Standard'),
  createParagraph(
    'Figure 4.1 displays the core TransactionModel and CategoryModel definitions. The TransactionModel stores amount strictly as an integer representing minor units (paisas) and exposes an amountInMajorUnits getter that divides by 100.0 for UI display. It implements comprehensive toMap() and fromMap() methods for seamless SQLite database serialization while preserving strict null-safety and immutable field definitions.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• Integer paisas eliminate IEEE 754 precision errors across balances and comparisons.\n• toMap() and fromMap() provide bidirectional SQLite serialization with safe null checks.\n• CategoryModel associates hex color strings and Material icon identifiers for dynamic styling.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.2 Dossier (Page 7)
  createHeading2('4.2 SQLite Database Setup and Schema Management'),
  createImage('evidence/code/02_database_setup_evidence.png', 460, 230),
  createCaption('Figure 4.2: lib/core/database/app_database.dart — Database Singleton, FFI Setup & Foreign Keys'),
  createParagraph(
    'Figure 4.2 illustrates the AppDatabase singleton lifecycle. The class initializes desktop FFI drivers (sqfliteFfiInit) on Windows, macOS, and test runners, enabling cross-platform SQLite execution. In the _onConfigure callback, PRAGMA foreign_keys = ON is executed to guarantee referential integrity across categories, transactions, and budgets. The _onCreate callback seeds default categories inside an atomic SQLite transaction.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• sqfliteFfiInit allows desktop Windows/Linux execution and fast headless unit tests.\n• PRAGMA foreign_keys = ON enforces relational cascade integrity across all queries.\n• Pre-seeded categories are inserted atomically inside a single SQLite transaction block.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.3 Dossier (Page 8)
  createHeading2('4.3 Parameterized SQLite CRUD Operations'),
  createImage('evidence/code/01_database_crud_evidence.png', 460, 230),
  createCaption('Figure 4.3: lib/core/database/database_service.dart — Parameterized SQLite CRUD & Net Balance Engine'),
  createParagraph(
    'Figure 4.3 shows the Data Access Object (DatabaseService) implementing parameterized insert, query, update, and delete methods. All SQL executions utilize parameter substitution (? placeholders) to prevent SQL injection vulnerabilities. The getTotalBalance() query directly performs SQL aggregation (SUM(amount)) across income and expense types, returning the net balance in integer minor units.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• 100% Parameterized queries guard against SQL injection vulnerabilities across all inputs.\n• SQL SUM(amount) aggregation executes directly in SQLite for high performance.\n• Atomic transaction wrappers guarantee database consistency during multi-row updates.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.4 Dossier (Page 9)
  createHeading2('4.4 Form Validation & Submission Safeguards'),
  createImage('evidence/code/03_form_validation_evidence.png', 460, 230),
  createCaption('Figure 4.4: lib/features/transactions/screens/add_transaction_screen.dart — Robust Form Validation'),
  createParagraph(
    'Figure 4.4 details the _submitForm() method in AddTransactionScreen. The validation pipeline guards against duplicate submissions (_isSubmitting flag), enforces FormKey validation, ensures category selection, parses input into minor units, and enforces a 100 Million PKR upper ceiling. Upon successful validation, the controller persists the record to SQLite and navigates back seamlessly.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• Double-submission guard (_isSubmitting flag) prevents accidental duplicate entries.\n• Boundary validation rejects zero, negative amounts, and values over PKR 100 Million.\n• Immediate minor-unit parsing guarantees financial precision prior to database insert.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.5 Dossier (Page 10)
  createHeading2('4.5 Monthly Budget Management & Threshold Calculations'),
  createImage('evidence/code/04_budget_controller_evidence.png', 460, 230),
  createCaption('Figure 4.5: lib/core/controllers/budget_controller.dart — Budget Aggregations & Threshold Alerts'),
  createParagraph(
    'Figure 4.5 highlights the BudgetController metrics engine. The controller queries SQLite for all category budgets in the selected month, aggregates total spending caps and actual expenditures, and computes threshold alert getters: isWarning (80% to 99% of cap) and isOverBudget (100% or greater). These getters drive real-time visual indicator cards across the UI.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• Automated threshold getters dynamically classify budget health (<80%, 80-99%, >=100%).\n• Real-time aggregation of total monthly pool limit against current actual spending.\n• Zero-division checks protect against empty budget allocations during calculation.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.6 Dossier (Page 11)
  createHeading2('4.6 History Filtering & Proportional Spending Visualization'),
  createImage('evidence/code/05_history_and_viz_evidence.png', 460, 230),
  createCaption('Figure 4.6: lib/features/history/widgets/category_spending_visualization.dart — Filters & Proportional Bars'),
  createParagraph(
    'Figure 4.6 displays the spending visualization and dual-filtering implementation. The _calculatePercentage method includes a critical zero-division safeguard for months with no recorded expenses. The filteredTransactions getter applies dual filtering across both the active month-year key and selected category chip simultaneously.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• _calculatePercentage includes explicit total <= 0 check to guarantee zero-division safety.\n• Dual filtering query filters transactions by month-year key and category chip simultaneously.\n• Ranked category progress bars render exact percentage shares sorted by highest expense.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.7 Dossier (Page 12)
  createHeading2('4.7 Reactive State Management & Cross-Refresh'),
  createImage('evidence/code/02_transaction_controller_evidence.png', 460, 230),
  createCaption('Figure 4.7: lib/core/controllers/transaction_controller.dart — Reactive State & Cross-Controller Sync'),
  createParagraph(
    'Figure 4.7 demonstrates the TransactionController state manager extending ChangeNotifier. When a transaction is added, updated, or deleted, the controller reloads SQLite records and notifies all listening UI widgets. Crucially, it triggers BudgetController.refresh() to ensure the Budgets screen and Dashboard remaining budget cards reflect transaction changes immediately.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• Built with native Flutter ChangeNotifier, avoiding heavy third-party state libraries.\n• Cross-controller sync automatically invalidates and refreshes budget metrics on CRUD.\n• Immediate notifyListeners() ensures snappy 60fps UI updates across all open tabs.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Figure 4.8 Dossier (Page 13)
  createHeading2('4.8 5-Page Persistent Navigation Architecture'),
  createImage('evidence/code/03_navigation_scaffold_evidence.png', 460, 230),
  createCaption('Figure 4.8: lib/app/navigation/app_scaffold.dart — Persistent 5-Destination Shell with IndexedStack'),
  createParagraph(
    'Figure 4.8 depicts the AppScaffold navigation shell. By wrapping all 5 top-level destinations (Dashboard, History, Add, Budgets, Settings) inside an IndexedStack, the application preserves user scroll positions and in-progress form inputs when switching between tabs. The center Quick-Add button provides immediate access to transaction creation.'
  ),
  createCallout(
    'Key Architectural Highlights',
    '• IndexedStack navigation preserves widget tree state and scroll positions across tabs.\n• Center Quick-Add action button provides instant access to transaction creation form.\n• Clean separation between app shell navigation and feature-specific business logic.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 5: WEEKLY WORK PROGRESS (PAGES 14 TO 21)
  // Each Day spans exactly 2 balanced pages:
  // Page A: Overview + Table 1 (Screenshots 1 & 2)
  // Page B: Table 2 (Screenshots 3 & 4) + Architectural Takeaways Callout
  // ==========================================
  createHeading1('Section 5: Weekly Work Progress'),
  createParagraph(
    'Development of SpendWise occurred across four structured internship milestones from Monday, 2 November 2026 through Thursday, 5 November 2026, followed by final polish and verification on Friday, 6 November 2026. This section details the daily engineering objectives, tasks accomplished, and genuine visual evidence captured on each day.'
  ),

  // 5.1 Day 1 (Monday) - Page 14
  createHeading2('5.1 Day 1 — Project Foundation (Monday, 2 November 2026)'),
  createParagraph(
    'Objective: Establish the SpendWise Flutter foundation, build the bespoke purple/violet fintech design system, create the 5-page navigation scaffold, and define the core data models and SQLite database DDL queries.'
  ),
  createBullet('Engineered the Material 3 design system with primary color #6536C7, custom gradients, elevation tokens, and standardized typography.', 'UI Architecture:'),
  createBullet('Created the AppScaffold with a persistent bottom navigation bar linking Dashboard, History, Add Transaction, Budgets, and Settings.', 'Navigation:'),
  createBullet('Implemented immutable TransactionModel and CategoryModel classes with integer minor currency unit support.', 'Data Models:'),
  createBullet('Architected AppDatabase singleton with SQLite table schemas for categories and transactions, including pre-seeded default categories.', 'Database Engine:'),
  createParagraph('Genuine visual evidence captured on Day 1 is shown below:'),
  createSideBySideScreenshots(
    'evidence/screenshots/01_dashboard_screen.png',
    'Figure 5.1: Day 1 Dashboard (Hero Net Balance & Sample Preview)',
    'evidence/screenshots/02_add_transaction_screen.png',
    'Figure 5.2: Day 1 Add Transaction Form Layout'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.1 Day 1 (Monday) - Page 15
  createHeading3('Day 1 Extended Interface Evidence & Takeaways'),
  createSideBySideScreenshots(
    'evidence/screenshots/03_history_screen.png',
    'Figure 5.3: Day 1 Transaction History View',
    'evidence/screenshots/04_budgets_screen.png',
    'Figure 5.4: Day 1 Budgets Screen Foundation'
  ),
  createCallout(
    'Day 1 Architectural Milestones & Key Takeaways',
    '• Successfully initialized clean architectural folder structure: app, core, features, models.\n• Integrated SQLite database initialization with cross-platform sqflite_common_ffi.\n• Established minor-currency units standard (PKR Paisas) from Day 1 to eliminate float drift.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.2 Day 2 (Tuesday) - Page 16
  createHeading2('5.2 Day 2 — Transaction Management (Tuesday, 3 November 2026)'),
  createParagraph(
    'Objective: Transition from sample preview mode to a fully functional local transaction management system backed by SQLite CRUD operations, form validation, and reactive dashboard calculations.'
  ),
  createBullet('Implemented functional Income and Expense transaction recording with amount entry, date picker, category selection chips, and notes.', 'Transaction Creation:'),
  createBullet('Added strict form validation: empty amount rejection, zero and negative amount blocking, and 100 Million PKR upper ceiling.', 'Form Validation:'),
  createBullet('Built complete SQLite CRUD queries in DatabaseService (insert, update, delete, getTransactionsByMonth) with newest-first sorting.', 'SQLite Integration:'),
  createBullet('Integrated TransactionController using ChangeNotifier to dynamically recalculate Monthly Income, Monthly Expenses, and Total Net Balance.', 'Reactive Aggregation:'),
  createParagraph('Genuine visual evidence captured on Day 2 is shown below:'),
  createSideBySideScreenshots(
    'evidence/day_2/02_add_expense.png',
    'Figure 5.5: Day 2 Functional Add Expense Form',
    'evidence/day_2/03_add_income.png',
    'Figure 5.6: Day 2 Functional Add Income Form'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.2 Day 2 (Tuesday) - Page 17
  createHeading3('Day 2 Transaction Edit and Deletion Workflows'),
  createSideBySideScreenshots(
    'evidence/day_2/05_edit_transaction.png',
    'Figure 5.7: Day 2 Edit Transaction Pre-filled Mode',
    'evidence/day_2/06_delete_confirmation.png',
    'Figure 5.8: Day 2 Delete Confirmation Dialog'
  ),
  createCallout(
    'Day 2 Architectural Milestones & Key Takeaways',
    '• Replaced all hardcoded preview cards with live parameterized SQLite queries.\n• Implemented double-submission safeguards on AddTransactionScreen submit buttons.\n• Validated reactive UI updates: adding an income immediately updates net balance hero card.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.3 Day 3 (Wednesday) - Page 18
  createHeading2('5.3 Day 3 — Monthly Budget Management (Wednesday, 4 November 2026)'),
  createParagraph(
    'Objective: Implement the complete Monthly Budget Management milestone with category spending caps, real-time threshold progress tracking, automated warning indicators, and dashboard integration.'
  ),
  createBullet('Built BudgetModel entity and budgets SQLite table with UNIQUE(category_id, month_year) constraint to prevent duplicate allocations.', 'Budget Schema:'),
  createBullet('Engineered BudgetFormSheet bottom modal supporting creation and editing of category spending caps with validation.', 'Budget Modal:'),
  createBullet('Implemented automated threshold indicators: On Track (<80%), Warning / Near Limit (80%–99%), and Over-Budget (≥100%) with red alert badges.', 'Threshold System:'),
  createBullet('Integrated cross-refresh mechanics so modifying transactions immediately updates category budget progress bars and dashboard remaining budget cards.', 'Cross-Screen Sync:'),
  createParagraph('Genuine visual evidence captured on Day 3 is shown below:'),
  createSideBySideScreenshots(
    'evidence/day_3/01_budgets_dashboard.png',
    'Figure 5.9: Day 3 Monthly Budgets Screen Overview',
    'evidence/day_3/02_add_monthly_budget.png',
    'Figure 5.10: Day 3 Add Category Budget Modal Sheet'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.3 Day 3 (Wednesday) - Page 19
  createHeading3('Day 3 Threshold Alert Cards & Warning States'),
  createSideBySideScreenshots(
    'evidence/day_3/05_warning_status.png',
    'Figure 5.11: Day 3 Warning Status Alert Card (80%–99%)',
    'evidence/day_3/06_over_budget.png',
    'Figure 5.12: Day 3 Over-Budget Danger Card (≥100%)'
  ),
  createCallout(
    'Day 3 Architectural Milestones & Key Takeaways',
    '• Database UNIQUE constraint guarantees each category has at most one budget per month.\n• Engineered 80% warning and 100% danger thresholds with high-visibility fintech badges.\n• Connected BudgetController with TransactionController for seamless cross-screen reactivity.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.4 Day 4 (Thursday) - Page 20
  createHeading2('5.4 Day 4 — History Filters & Spending Visualization (Thursday, 5 November 2026)'),
  createParagraph(
    'Objective: Implement functional month filtering, category chip filtering, combined dual filtering, proportional category spending breakdown bars, empty states, and responsive layout validation.'
  ),
  createBullet('Added interactive month selector navigation pills allowing smooth traversal between previous, current, and future months.', 'Month Filtering:'),
  createBullet('Built horizontal scrollable category filter bar enabling single-tap category isolation with clear-filter shortcuts.', 'Category Filtering:'),
  createBullet('Engineered CategorySpendingVisualization widget rendering proportional horizontal progress bars with percentage shares.', 'Spending Breakdown:'),
  createBullet('Implemented zero-division safeguards and verified clean responsive rendering on compact mobile screens (360dp width) with zero overflows.', 'Responsive & Robust:'),
  createParagraph('Genuine visual evidence captured on Day 4 is shown below:'),
  createSideBySideScreenshots(
    'evidence/day_4/01_history_month_selector.png',
    'Figure 5.13: Day 4 Month Selector Navigation Pill',
    'evidence/day_4/03_combined_filters.png',
    'Figure 5.14: Day 4 Combined Month & Category Filter'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // 5.4 Day 4 (Thursday) - Page 21
  createHeading3('Day 4 Spending Analytics & Responsive Layout Verification'),
  createSideBySideScreenshots(
    'evidence/day_4/04_spending_visualization.png',
    'Figure 5.15: Day 4 Category Spending Breakdown Mode',
    'evidence/day_4/07_responsive_small_screen.png',
    'Figure 5.16: Day 4 Small-Screen Responsive Layout (360dp)'
  ),
  createCallout(
    'Day 4 Architectural Milestones & Key Takeaways',
    '• Multi-axis SQLite filtering allows combining month selection and category filtering.\n• Category spending visualization ranks categories by expenditure share with color matching.\n• Tested responsive layouts across small mobile viewports (360dp width) with 0 pixel overflows.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 6: SCREENSHOTS OF COMPLETED WORK (PAGES 22 TO 26)
  // 5 Side-by-Side Tables across 5 dedicated pages
  // ==========================================
  createHeading1('Section 6: Screenshots of Completed Work'),
  createParagraph(
    'This section showcases the comprehensive visual gallery of all completed screens and user interaction states in SpendWise. All screenshots are high-resolution captures from the running application.'
  ),

  // Page 22: Dashboard & Income
  createHeading2('6.1 Dashboard & Transaction Creation'),
  createSideBySideScreenshots(
    'evidence/final_submission/01_dashboard.png',
    'Figure 6.1: Executive Dashboard (Hero Balance, Income/Expense & Recent Ledger)',
    'evidence/final_submission/02_add_income.png',
    'Figure 6.2: Add Income Form (Salary/Freelance Chips & Presets)'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 23: Expense & Validation
  createHeading3('6.1.1 Expense Logging & Validation Defense'),
  createSideBySideScreenshots(
    'evidence/final_submission/03_add_expense.png',
    'Figure 6.3: Add Expense Form (Category Selection & Date Picker)',
    'evidence/final_submission/09_validation_errors.png',
    'Figure 6.4: Form Validation Error State (Empty Amount Guard)'
  ),
  createCallout(
    'Validation & Integrity Safeguards',
    'SpendWise enforces strict multi-level validation: rejection of empty fields, non-numeric strings, negative numbers, and values exceeding PKR 100 Million. Form error messages clearly direct users to correct inputs without losing unsubmitted data.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 24: Monthly Budgets Overview & Alerts
  createHeading2('6.2 Monthly Budgets & Warning Triggers'),
  createParagraph(
    'The monthly budget system aggregates category limits against actual monthly expenses. Visual cards shift dynamically from violet (On Track) to amber (Near Limit at 80%) and red (Over Budget at 100% or greater).'
  ),
  createSideBySideScreenshots(
    'evidence/final_submission/04_monthly_budgets.png',
    'Figure 6.5: Monthly Budgets Screen (Pool Gauge & Spending Caps)',
    'evidence/final_submission/05_budget_warning_overbudget.png',
    'Figure 6.6: Budget Alert Cards (Warning 85% & Over-Budget 108%)'
  ),
  createCallout(
    'Automated Threshold Detection Engine',
    'Threshold calculations execute in real-time on the client machine: Food & Dining at 85% triggers a warning pill, while Bills & Utilities at 108% triggers an over-budget badge and warning banner.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 25: History Filters & Spending Breakdown
  createHeading2('6.3 History Filters & Category Spending Visualization'),
  createParagraph(
    'The transaction ledger supports multi-axis filtering by calendar month and dynamic category chips, accompanied by proportional spending breakdown analytics.'
  ),
  createSideBySideScreenshots(
    'evidence/final_submission/06_history_combined_filters.png',
    'Figure 6.7: History Screen with Combined Month & Category Filters',
    'evidence/final_submission/07_category_spending_visualization.png',
    'Figure 6.8: Proportional Category Spending Breakdown & Percentage Share'
  ),
  createCallout(
    'Multi-Axis Ledger Isolation',
    'Users can isolate specific expenditures across any historical month and category simultaneously. Clear filter shortcuts provide rapid resets, and spending bars rank costs by magnitude.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 26: Empty State & Settings Storage
  createHeading3('6.3.1 Empty State Handling & System Storage Diagnostics'),
  createSideBySideScreenshots(
    'evidence/final_submission/08_empty_state.png',
    'Figure 6.9: Contextual Empty State View for Period without Data',
    'evidence/final_submission/10_settings_storage.png',
    'Figure 6.10: Settings Screen & Live SQLite Database Diagnostic Tool'
  ),
  createCallout(
    'Storage Engine Integrity & Production Polish',
    'When no transactions exist for a selected filter period, SpendWise displays an intuitive illustration and quick-action button. The Settings screen provides live database diagnostics, table row counts, and storage metrics.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 7: FINAL OUTPUT SCREENSHOTS (PAGES 27 & 28)
  // Flagship Screenshots presented elegantly
  // ==========================================
  createHeading1('Section 7: Final Output Screenshots'),
  createParagraph(
    'The final output screenshots below document the completed, fully integrated application operating with authentic financial transaction data. Each screen demonstrates the seamless coordination between SQLite persistence, ChangeNotifier reactive state, and the signature purple/violet fintech design system.'
  ),

  // Page 27: Executive Dashboard & Budgets side-by-side
  createHeading2('7.1 Flagship Screens: Executive Dashboard & Budget Alert System'),
  createSideBySideScreenshots(
    'evidence/final_submission/01_dashboard.png',
    'Figure 7.1: Final Output — Executive Financial Dashboard (PKR 213,000.00 Net Balance)',
    'evidence/final_submission/05_budget_warning_overbudget.png',
    'Figure 7.2: Final Output — Monthly Budget Management with Real-Time Alerts'
  ),
  createParagraph(
    'Figure 7.1 and 7.2 present the core operational cockpits of SpendWise. The Executive Dashboard aggregates lifetime income (PKR 250,000.00) and expenses (PKR 37,000.00) to present a net balance of PKR 213,000.00. The remaining budget card shows PKR 14,000.00 safe to spend from the PKR 51,000.00 monthly cap. On the Budgets screen, the real-time threshold engine flags Food & Dining at 85% (Near Limit) and Bills & Utilities at 108% (Over Budget).'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 28: Ranked Category Spending Breakdown
  createHeading2('7.2 Proportional Category Spending Breakdown & System Verification'),
  createParagraph(
    'Figure 7.3 illustrates the Category Spending Breakdown mode. Expenditures are categorized, calculated into exact percentage shares, and ranked from largest to smallest: Food & Dining (34.3% / PKR 12,700), Shopping & Gear (32.4% / PKR 12,000), Bills & Utilities (17.6% / PKR 6,500), and Transportation (15.7% / PKR 5,800). Each category renders an animated horizontal bar colored by its distinct theme token.'
  ),
  createImage('evidence/final_submission/07_category_spending_visualization.png', 165, 365),
  createCaption('Figure 7.3: Final Output — Ranked Horizontal Category Spending Distribution'),
  createCallout(
    'Final Output Verification Summary',
    '• Net Financial Balance: PKR 213,000.00 calculated accurately via SQLite SQL aggregation.\n• Monthly Safe-to-Spend Allowance: PKR 14,000.00 dynamically derived across 4 active category budgets.\n• Visual Categorical Distribution: Ranked horizontal bars with exact percentage shares and 0-division safeguards.\n• Completely Offline & Private: 100% of data generated, processed, and displayed locally on client device.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 8: WEEKLY SUMMARY (EXACTLY 10 POINTS) (PAGE 29)
  // Single, complete, balanced page
  // ==========================================
  createHeading1('Section 8: Weekly Summary (Exactly 10 Points)'),
  createParagraph(
    'The following ten points summarize the end-to-end engineering achievements accomplished during Week 02 of the Stack & Scale Remote Internship 2026 for SpendWise:'
  ),

  createBullet(
    'Set up the SpendWise Flutter application and established its clean layered architecture (app, core, features, models) and persistent 5-destination IndexedStack navigation.',
    '1. Architecture & Setup:'
  ),
  createBullet(
    'Designed a consistent, polished Material 3 user interface featuring a signature purple/violet brand palette (#6536C7), custom elevation tokens, lavender cards, and responsive typography.',
    '2. Fintech Design System:'
  ),
  createBullet(
    'Integrated SQLite (sqflite and sqflite_common_ffi) for 100% offline-first local data storage, configuring foreign key constraints (PRAGMA foreign_keys = ON) and automatic category pre-seeding.',
    '3. SQLite Integration:'
  ),
  createBullet(
    'Implemented comprehensive income and expense transaction recording with exact amount entry, custom category chips, date picker selection, and optional descriptive notes.',
    '4. Transaction Operations:'
  ),
  createBullet(
    'Added rigorous form validation, double-submission prevention, and complete transaction CRUD operations (Create, Read, Update, Delete) with SQLite transaction updates.',
    '5. Validation & CRUD:'
  ),
  createBullet(
    'Implemented monthly category budgets with create, edit, and delete functionality, enforcing relational integrity and duplicate prevention via a UNIQUE(category_id, month_year) schema rule.',
    '6. Monthly Budgeting:'
  ),
  createBullet(
    'Developed accurate financial calculations, budget progress indicators, automated 80% warning triggers, and 100% over-budget danger alerts with real-time UI synchronization.',
    '7. Budget Warning System:'
  ),
  createBullet(
    'Added interactive month-based navigation pills, category-based filtering chips, and combined dual-filter queries in the transaction history ledger.',
    '8. Multi-Axis Filtering:'
  ),
  createBullet(
    'Implemented category-wise spending visualization featuring ranked proportional progress bars and exact percentage calculations with zero-division safeguards.',
    '9. Spending Visualization:'
  ),
  createBullet(
    'Performed exhaustive automated testing (37/37 tests passing), static analysis (0 analyzer issues), responsive layout verification on compact screens, and organized all project evidence.',
    '10. QA & Verification:'
  ),

  new Paragraph({ spacing: { before: 120, after: 30 } }),
  createCallout(
    'Internship Deliverable Milestone Completion',
    'All ten weekly objectives established in the Stack & Scale Week 02 curriculum have been fully implemented, rigorously tested, verified across multiple device profiles, and documented for final evaluation.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 9: TESTING AND VERIFICATION (PAGES 30 & 31)
  // Page 30: 9.1 & 9.2 Verification Table
  // Page 31: 9.3 Test Breakdown & QA Callout
  // ==========================================
  createHeading1('Section 9: Testing and Verification'),
  createParagraph(
    'Quality assurance and automated testing formed an integral part of the SpendWise engineering workflow throughout the internship. All features were validated through comprehensive test suites to ensure zero regressions across releases.'
  ),

  createHeading2('9.1 Day 4 Reported Milestone Results'),
  createParagraph(
    'At the conclusion of Day 4 development, the following verified milestone metrics were officially recorded:'
  ),
  createBullet('Flutter Analyze: Clean execution with 0 issues, errors, or linter warnings across the entire codebase.', '• Static Analysis:'),
  createBullet('Automated Test Suite: Complete test suite of 37 automated tests passing in under 14 seconds.', '• Test Suite:'),
  createBullet('Debug APK: Successfully compiled Android debug APK via Flutter build pipeline without Gradle failures.', '• Binary Build:'),
  createBullet('Visual Evidence: Seven high-resolution screenshots generated and cataloged in evidence/day_4/.', '• Day 4 Evidence:'),

  createHeading2('9.2 Day 5 Final Verification & Handover Results'),
  createParagraph(
    'On Day 5, comprehensive regression testing, static analysis, and release-ready binary compilation were executed. The final verified results are documented below:'
  ),

  createDataTable(
    ['Verification Category', 'Command Executed', 'Observed Result', 'Quality Status'],
    [
      ['Static Code Analysis', 'flutter analyze', 'No issues found! (ran in 7.2s)', '100% PASS'],
      ['Unit & Model Tests', 'flutter test test/widget_test.dart', 'All 6 unit/currency tests passed', '100% PASS'],
      ['SQLite Database Tests', 'flutter test test/database_test.dart', 'All 6 database CRUD tests passed', '100% PASS'],
      ['Budget & Math Tests', 'flutter test test/budget_test.dart', 'All 15 budget calculation tests passed', '100% PASS'],
      ['History & Filter Tests', 'flutter test test/history_filter_test.dart', 'All 10 filter & viz tests passed', '100% PASS'],
      ['Total Automated Tests', 'flutter test', '37 passed out of 37 tests (ran in 8.9s)', '100% PASS'],
      ['Android Binary Build', 'flutter build apk --debug', 'Built app-debug.apk (156.8 MB) in 598.8s', '100% PASS'],
      ['Demonstration Video', 'ffmpeg (1080p Full HD)', 'Compiled SpendWise_Week2_Demonstration.mp4', '100% PASS'],
    ],
    true // compact table
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 31: 9.3 Test Suite Breakdown & QA Callout
  createHeading2('9.3 Automated Test Suite Breakdown'),
  createParagraph(
    'The automated test suite exercises all layers of the application stack, guaranteeing mathematical correctness and data integrity:'
  ),
  createBullet('Validates TransactionModel and CategoryModel serialization, amount conversion to major/minor units, and CurrencyFormatter parsing rules.', '1. Model & Currency Tests:'),
  createBullet('Verifies SQLite table creation, foreign key enforcement, newest-first ordering, parameterized updates, deletions, and SQL net balance calculation.', '2. Database Operations:'),
  createBullet('Tests budget creation, edit without duplication, limit validation, remaining allowance math, 80% warning triggers, 100% over-budget alerts, and persistence after simulated restart.', '3. Budget Calculations:'),
  createBullet('Verifies month filtering, category filtering, combined dual filtering, clear filters, December-to-January boundary handling, and zero-division safety on empty months.', '4. History & Filters:'),
  createBullet('Validates form submission guards, empty amount rejection, zero and negative amount blocking, and multi-step UI CRUD workflows.', '5. Form Validation:'),

  new Paragraph({ spacing: { before: 120, after: 30 } }),
  createCallout(
    'Quality Assurance & Continuous Testing Guarantee',
    'SpendWise maintains 100% pass rates across all 37 automated tests with zero static analysis warnings. Automated test suites run in headless environments with SQLite FFI drivers, enabling robust automated verification.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 10: CONCLUSION AND LEARNING (PAGES 32 & 33)
  // Page 32: 10.1 Key Technical Competencies Acquired (8 items)
  // Page 33: 10.2 AI Disclosure, 10.3 Concluding Statement & Sign-off
  // ==========================================
  createHeading1('Section 10: Conclusion and Learning'),
  createParagraph(
    'The Stack & Scale Remote Internship 2026 Week 02 project—SpendWise—provided an exceptional opportunity to engineer a real-world, production-ready fintech application from concept to deployment. Through daily milestones, foundational software engineering principles were put into practice, emphasizing code clarity, architectural discipline, and rigorous verification.'
  ),

  createHeading2('10.1 Key Technical Competencies Acquired'),
  createBullet(
    'Developed proficiency in crafting custom, theme-driven fintech interfaces using Material 3 color tokens, linear gradients, dynamic elevations, and responsive layout constraints that prevent pixel overflow across compact mobile viewports.',
    '1. Advanced Flutter UI/UX:'
  ),
  createBullet(
    'Gained hands-on mastery of relational SQLite schemas, database lifecycle singletons, PRAGMA foreign_keys enforcement, automated category seeding, and parameterized queries that protect against SQL injection vulnerabilities.',
    '2. Embedded SQLite Architecture:'
  ),
  createBullet(
    'Implemented full Create, Read, Update, and Delete lifecycles across multiple relational tables with proper error handling, state synchronization, and data permanence across simulated app restarts.',
    '3. Relational CRUD Engineering:'
  ),
  createBullet(
    'Designed multi-step form validation logic incorporating double-submission guards, input sanitization, type-safe currency parsing, and immediate visual user feedback.',
    '4. Defensive Form Validation:'
  ),
  createBullet(
    'Constructed clean, maintainable reactive state architectures using native Flutter ChangeNotifiers, avoiding third-party library overhead while achieving instantaneous cross-screen state synchronization.',
    '5. Reactive State Management:'
  ),
  createBullet(
    'Adopted the industry-standard minor currency units standard (storing integer paisas) to eliminate floating-point precision loss, implementing robust budget threshold math and zero-division safeguards.',
    '6. Fintech Precision Arithmetic:'
  ),
  createBullet(
    'Architected multi-axis historical data querying, combining month navigation pills with dynamic category chips, and implemented ranked proportional progress bar visualizations.',
    '7. Data Filtering & Visualization:'
  ),
  createBullet(
    'Cultivated disciplined testing practices by authoring 37 automated unit, widget, and database tests, guaranteeing that new feature implementations did not introduce regressions.',
    '8. Quality Assurance & Testing:'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Page 33: 10.2 AI Disclosure, 10.3 Concluding Statement & Sign-off
  createHeading2('10.2 Artificial Intelligence Collaboration Disclosure'),
  createParagraph(
    'In accordance with internship transparency and academic integrity guidelines, artificial intelligence assistance (Antigravity by Google DeepMind) was utilized during the development of SpendWise. AI tooling was engaged as an advanced pair-programming partner for architectural planning, algorithmic review, test case design, debugging complex SQLite query interactions, and drafting technical documentation. All application source code, database structures, UI components, test assertions, and build outputs were actively verified, executed, and validated by the developer on the local development machine.'
  ),

  createHeading2('10.3 Final Concluding Statement'),
  createParagraph(
    'SpendWise successfully achieves all primary and stretch requirements established for Week 02 of the Stack & Scale Remote Internship 2026. The application stands as an exemplary demonstration of an offline-first, mathematically precise, and aesthetically refined personal finance solution. The project has profoundly expanded the developer\'s capabilities in mobile software engineering, database design, and automated software verification.'
  ),

  new Paragraph({ spacing: { before: 100, after: 0 } }),
  createCallout(
    'Documentation Sign-off',
    'Report authored by Nida Fatima for Stack & Scale Remote Internship 2026 — Week 02. Completed and verified on 06 November 2026.'
  ),
];

// Document Definition with Headers, Footers, and Page Setup
const doc = new Document({
  styles: {
    default: {
      document: {
        run: {
          font: 'Segoe UI',
          color: COLOR_TEXT,
        },
      },
    },
  },
  sections: [
    {
      properties: {
        page: {
          size: {
            width: 11906,  // A4 width in twips (8.27 in)
            height: 16838, // A4 height in twips (11.69 in)
          },
          margin: {
            top: 1152,    // 0.8 in
            bottom: 1152, // 0.8 in
            left: 1152,   // 0.8 in
            right: 1152,  // 0.8 in
          },
        },
      },
      headers: {
        default: new Header({
          children: [
            new Table({
              width: { size: 100, type: WidthType.PERCENTAGE },
              borders: {
                top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                bottom: { style: BorderStyle.SINGLE, size: 8, color: COLOR_PRIMARY },
              },
              rows: [
                new TableRow({
                  cantSplit: true,
                  children: [
                    new TableCell({
                      width: { size: 50, type: WidthType.PERCENTAGE },
                      borders: {
                        top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                      },
                      children: [
                        new Paragraph({
                          children: [
                            new TextRun({
                              text: 'SpendWise — Weekly Project Documentation',
                              bold: true,
                              size: 18, // 9pt
                              color: COLOR_PRIMARY,
                              font: 'Segoe UI Semibold',
                            }),
                          ],
                        }),
                      ],
                    }),
                    new TableCell({
                      width: { size: 50, type: WidthType.PERCENTAGE },
                      borders: {
                        top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                      },
                      children: [
                        new Paragraph({
                          alignment: AlignmentType.RIGHT,
                          children: [
                            new TextRun({
                              text: 'Stack & Scale Internship 2026 • Week 02',
                              size: 18,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                          ],
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
          ],
        }),
      },
      footers: {
        default: new Footer({
          children: [
            new Table({
              width: { size: 100, type: WidthType.PERCENTAGE },
              borders: {
                top: { style: BorderStyle.SINGLE, size: 6, color: COLOR_BORDER },
                left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
              },
              rows: [
                new TableRow({
                  cantSplit: true,
                  children: [
                    new TableCell({
                      width: { size: 40, type: WidthType.PERCENTAGE },
                      borders: {
                        top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                      },
                      children: [
                        new Paragraph({
                          children: [
                            new TextRun({
                              text: 'Developer: Nida Fatima (Flutter)',
                              size: 18,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                          ],
                        }),
                      ],
                    }),
                    new TableCell({
                      width: { size: 30, type: WidthType.PERCENTAGE },
                      borders: {
                        top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                      },
                      children: [
                        new Paragraph({
                          alignment: AlignmentType.CENTER,
                          children: [
                            new TextRun({
                              text: 'Confidential Report',
                              size: 17,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                          ],
                        }),
                      ],
                    }),
                    new TableCell({
                      width: { size: 30, type: WidthType.PERCENTAGE },
                      borders: {
                        top: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        left: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        right: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                        bottom: { style: BorderStyle.NONE, size: 0, color: 'auto' },
                      },
                      children: [
                        new Paragraph({
                          alignment: AlignmentType.RIGHT,
                          children: [
                            new TextRun({
                              text: 'Page ',
                              size: 18,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                            new TextRun({
                              children: [PageNumber.CURRENT],
                              size: 18,
                              color: COLOR_PRIMARY,
                              bold: true,
                              font: 'Segoe UI',
                            }),
                            new TextRun({
                              text: ' of ',
                              size: 18,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                            new TextRun({
                              children: [PageNumber.TOTAL_PAGES],
                              size: 18,
                              color: COLOR_MUTED,
                              font: 'Segoe UI',
                            }),
                          ],
                        }),
                      ],
                    }),
                  ],
                }),
              ],
            }),
          ],
        }),
      },
      children: docChildren,
    },
  ],
});

// Write to documentation/SpendWise_Weekly_Project_Documentation.docx
const outputPath = path.resolve('documentation/SpendWise_Weekly_Project_Documentation.docx');

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(outputPath, buffer);
  console.log('SUCCESS: Generated Microsoft Word documentation:');
  console.log('Path:', outputPath);
  console.log('Size:', (buffer.length / 1024 / 1024).toFixed(2), 'MB');
}).catch(err => {
  console.error('ERROR generating Word documentation:', err);
  process.exit(1);
});
