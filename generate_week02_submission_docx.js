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

// Color Palette Tokens
const COLOR_PRIMARY = '6536C7';      // Deep Violet / Purple
const COLOR_PRIMARY_LIGHT = '7E4EE0';// Violet Light
const COLOR_SURFACE = 'F6F4FD';      // Lavender Surface
const COLOR_SURFACE_LIGHT = 'FDFBFE';// Off-white
const COLOR_TEXT = '1E1B2E';         // Charcoal Primary Text
const COLOR_MUTED = '6B7280';        // Muted Slate Text
const COLOR_BORDER = 'D8D0F5';       // Subtle Violet Border
const COLOR_WHITE = 'FFFFFF';

// Helper to safely load image as ImageRun with keepWithNext
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
          color: 'EF4444',
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

// Helper for image caption
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

// Side-by-side two mobile screenshots table with cantSplit
function createSideBySideScreenshots(img1Path, cap1, img2Path, cap2) {
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

// Headings
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
        size: 28, // 14pt
        color: COLOR_PRIMARY,
        font: 'Segoe UI Semibold',
      }),
    ],
  });
}

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
        size: 23, // 11.5pt
        color: COLOR_PRIMARY_LIGHT,
        font: 'Segoe UI Semibold',
      }),
    ],
  });
}

function createHeading3(title) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 130, after: 50 },
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

// Body paragraph
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

// Bullet item
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

// Callout / Note card
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

// Styled Data Table helper
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

console.log('Building SpendWise Week 02 Weekly Submission Document...');

// Document Content Elements
const docChildren = [
  // ==========================================
  // COVER PAGE (PAGE 1)
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
                    text: 'WEEK 02 — OFFICIAL WEEKLY SUBMISSION REPORT',
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
                    text: 'Weekly Project Progress, Evidence Screenshots, Features & Learning Outcomes',
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

  // Submission Metadata Table
  createDataTable(
    ['Submission Field', 'Details & Evaluation Metadata'],
    [
      ['Internship Cohort', 'Stack & Scale Remote Internship 2026 — Cohort Evaluation'],
      ['Project Name', 'SpendWise — Personal Budget & Expense Tracker'],
      ['Milestone Track', 'Week 02 Weekly Progress & Final Project Submission'],
      ['Intern / Developer', 'Nida Fatima'],
      ['Internship Period', '02 November 2026 – 06 November 2026 (Days 1 to 5)'],
      ['Architecture Type', 'Offline-First Client-Side Mobile Ledger'],
      ['Verification Status', '37 / 37 Automated Tests Passing • 0 Linter Warnings'],
      ['Submission Scope', 'Progress Screenshots (Days 1–5), Final Output, Features & Outcomes'],
    ],
    true // compact
  ),

  new Paragraph({ spacing: { before: 60, after: 20 } }),
  createCallout(
    'Internship Submission Certification',
    'This document constitutes the official Week 02 project submission for SpendWise under the Stack & Scale Remote Internship 2026. All screenshots, milestone logs, functional descriptions, and learning outcomes documented herein represent verified, authentic work completed and tested on the local development machine.',
    true
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 1: PROJECT TITLE, PURPOSE, AND SHORT OVERVIEW
  // ==========================================
  createHeading1('1. Project Title, Purpose, and Short Overview'),
  createParagraph(
    'Project Title: SpendWise — Personal Budget & Expense Tracker',
    { bold: true, color: COLOR_PRIMARY, size: 21 }
  ),

  createHeading2('1.1 Project Purpose'),
  createParagraph(
    'SpendWise is engineered to provide students, recent graduates, and early-career software professionals with a dependable, completely private, and mathematically exact personal finance tracking engine. Managing personal finances during early career transitions is frequently disrupted by complex cloud-based applications that demand financial credentials, enforce subscriptions, require persistent internet connectivity, or leak spending habits to commercial advertising networks.'
  ),
  createParagraph(
    'The core purpose of SpendWise is to restore complete financial autonomy to the user through an offline-first architecture. All transaction entries, category allocations, and monthly budget limits are stored directly on the physical client device. The application requires zero internet access, transmits zero telemetry, and guarantees zero floating-point calculation drift by modeling all monetary values in integer minor currency units (Pakistani Rupee Paisas).'
  ),

  createHeading2('1.2 Short Overview'),
  createParagraph(
    'SpendWise operates as an integrated financial cockpit built with an intuitive five-stage management lifecycle:'
  ),
  createBullet('Real-Time Balance Visualization: An executive hero card aggregates lifetime income and expenses to display immediate net cash balance, formatted in Pakistani Rupees (PKR).', '• Balance Overview:'),
  createBullet('Dual-Type Transaction Logging: Users capture income and expenses with dynamic category selection, custom notes, date picker selection, and immediate minor-unit conversion.', '• Transaction CRUD:'),
  createBullet('Proactive Category Budgeting: Users configure monthly spending caps per category, supported by automated visual warning alerts at 80% and over-budget alerts at 100%.', '• Spending Limits:'),
  createBullet('Multi-Axis Historical Filtering: A dedicated transaction ledger allows concurrent multi-month navigation pills and single-tap category isolation chips.', '• Ledger Filtering:'),
  createBullet('Proportional Category Analytics: Ranked horizontal progress bars display the exact percentage distribution of expenditures sorted by cost magnitude with zero-division safeguards.', '• Spending Analytics:'),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 2: DAY 1 TO DAY 5 TASK/PROGRESS SCREENSHOTS
  // ==========================================
  createHeading1('2. Day 1 to Day 5 Task/Progress Screenshots'),
  createParagraph(
    'This section presents genuine visual progress evidence captured across all five internship days (Monday, 2 November 2026 to Friday, 6 November 2026). Each day highlights key tasks accomplished alongside authentic application captures.'
  ),

  // Day 1
  createHeading2('2.1 Day 1: Project Foundation & Layout Shell (Monday, 2 November 2026)'),
  createParagraph(
    'Day 1 Tasks: Established the layered folder architecture (app, core, features, models), created the Material 3 signature purple/violet design tokens (#6536C7), implemented the persistent 5-tab bottom navigation shell, and created the initial data entities and database schema foundations.'
  ),
  createSideBySideScreenshots(
    'evidence/screenshots/01_dashboard_screen.png',
    'Figure 2.1: Day 1 Dashboard Foundation (Hero Balance & Structure)',
    'evidence/screenshots/02_add_transaction_screen.png',
    'Figure 2.2: Day 1 Add Transaction Form Layout Shell'
  ),
  createSideBySideScreenshots(
    'evidence/screenshots/03_history_screen.png',
    'Figure 2.3: Day 1 Transaction History View Foundation',
    'evidence/screenshots/04_budgets_screen.png',
    'Figure 2.4: Day 1 Monthly Budgets Foundation'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Day 2
  createHeading2('2.2 Day 2: Functional Transaction Management (Tuesday, 3 November 2026)'),
  createParagraph(
    'Day 2 Tasks: Replaced sample preview states with functional local database operations. Built dynamic Income and Expense forms with amount parsing, dynamic category chips, and date selection. Added input validation (empty rejection, ceiling checks), double-submission guards, and reactive net balance calculations.'
  ),
  createSideBySideScreenshots(
    'evidence/day_2/02_add_expense.png',
    'Figure 2.5: Day 2 Functional Add Expense Form',
    'evidence/day_2/03_add_income.png',
    'Figure 2.6: Day 2 Functional Add Income Form'
  ),
  createSideBySideScreenshots(
    'evidence/day_2/05_edit_transaction.png',
    'Figure 2.7: Day 2 Edit Transaction Pre-filled Mode',
    'evidence/day_2/06_delete_confirmation.png',
    'Figure 2.8: Day 2 Delete Confirmation Dialog'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Day 3
  createHeading2('2.3 Day 3: Monthly Budget Management (Wednesday, 4 November 2026)'),
  createParagraph(
    'Day 3 Tasks: Engineered monthly category spending caps with unique category-month constraints to prevent duplicate allocations. Built bottom sheet modal forms for limit editing. Developed real-time threshold calculations: On Track (<80%), Near Limit Warning (80%–99%), and Over-Budget Danger (≥100%) with cross-screen synchronization.'
  ),
  createSideBySideScreenshots(
    'evidence/day_3/01_budgets_dashboard.png',
    'Figure 2.9: Day 3 Monthly Budgets Screen Overview',
    'evidence/day_3/02_add_monthly_budget.png',
    'Figure 2.10: Day 3 Add Monthly Budget Sheet'
  ),
  createSideBySideScreenshots(
    'evidence/day_3/05_warning_status.png',
    'Figure 2.11: Day 3 Warning Status Alert Card (80%–99%)',
    'evidence/day_3/06_over_budget.png',
    'Figure 2.12: Day 3 Over-Budget Danger State (≥100%)'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Day 4
  createHeading2('2.4 Day 4: History Filters & Spending Visualization (Thursday, 5 November 2026)'),
  createParagraph(
    'Day 4 Tasks: Built multi-axis historical ledger querying combining calendar month navigation pills and horizontal category chips. Implemented proportional spending breakdown visualization featuring ranked horizontal bars and zero-division safeguards. Verified responsive layout on compact 360dp mobile viewports.'
  ),
  createSideBySideScreenshots(
    'evidence/day_4/01_history_month_selector.png',
    'Figure 2.13: Day 4 Month Selector Navigation Pill',
    'evidence/day_4/03_combined_filters.png',
    'Figure 2.14: Day 4 Combined Month & Category Filter'
  ),
  createSideBySideScreenshots(
    'evidence/day_4/04_spending_visualization.png',
    'Figure 2.15: Day 4 Category Spending Breakdown Mode',
    'evidence/day_4/07_responsive_small_screen.png',
    'Figure 2.16: Day 4 Small-Screen Responsive Layout (360dp)'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // Day 5
  createHeading2('2.5 Day 5: Final Polish, Validation & Storage Diagnostics (Friday, 6 November 2026)'),
  createParagraph(
    'Day 5 Tasks: Completed final end-to-end regression validation and UI refinement. Enforced multi-tier defensive form validation with clear inline error displays for empty or invalid amounts. Implemented database storage diagnostics in Settings, and refined contextual empty states across periods without data.'
  ),
  createSideBySideScreenshots(
    'evidence/final_submission/09_validation_errors.png',
    'Figure 2.17: Day 5 Form Validation Error State Guards',
    'evidence/final_submission/10_settings_storage.png',
    'Figure 2.18: Day 5 Settings & Database Storage Diagnostic Tool'
  ),
  createSideBySideScreenshots(
    'evidence/final_submission/08_empty_state.png',
    'Figure 2.19: Day 5 Contextual Empty State View',
    'evidence/final_submission/11_history_all.png',
    'Figure 2.20: Day 5 Full Transaction Ledger with Live Data'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 3: SCREENSHOTS OF THE FINAL WEEKLY PROJECT OUTPUT
  // ==========================================
  createHeading1('3. Screenshots of the Final Weekly Project Output'),
  createParagraph(
    'The screenshots below document the final, production-ready SpendWise application operating with authentic financial transaction data. Each capture demonstrates the seamless coordination between local relational persistence, reactive state updates, and the polished purple/violet fintech design system.'
  ),

  createHeading2('3.1 Executive Financial Dashboard & Proactive Monthly Budgets'),
  createSideBySideScreenshots(
    'evidence/final_submission/01_dashboard.png',
    'Figure 3.1: Final Output — Executive Financial Dashboard (PKR 213,000.00 Net Balance)',
    'evidence/final_submission/05_budget_warning_overbudget.png',
    'Figure 3.2: Final Output — Monthly Budget Management with Real-Time Alerts'
  ),
  createParagraph(
    'Figure 3.1 displays the completed Executive Dashboard. The hero card calculates an authentic net balance of PKR 213,000.00 derived from PKR 250,000.00 in monthly income and PKR 37,000.00 in total expenditures. The safe-to-spend card indicates PKR 14,000.00 remaining from the PKR 51,000.00 monthly allocation. Figure 3.2 illustrates the budget threshold alerts in real-time: Food & Dining at 85% expenditure triggers the amber Near Limit warning pill, while Bills & Utilities at 108% triggers the prominent red Over-Budget alert banner.'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  createHeading2('3.2 Multi-Axis History Filtering & Ranked Spending Breakdown'),
  createSideBySideScreenshots(
    'evidence/final_submission/06_history_combined_filters.png',
    'Figure 3.3: Final Output — Multi-Axis Filtered History Screen (Month + Category)',
    'evidence/final_submission/07_category_spending_visualization.png',
    'Figure 3.4: Final Output — Ranked Horizontal Category Spending Distribution'
  ),
  createParagraph(
    'Figure 3.3 highlights the dual-axis historical querying capability: filtering simultaneously by November 2026 and the Shopping & Gear category isolates the matching transaction instantly with header transaction counters. Figure 3.4 demonstrates the proportional Category Spending Breakdown mode. Expenditures are categorized, calculated into exact percentage shares, and ranked from largest to smallest: Food & Dining (34.3% / PKR 12,700), Shopping & Gear (32.4% / PKR 12,000), Bills & Utilities (17.6% / PKR 6,500), and Transportation (15.7% / PKR 5,800).'
  ),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 4: COMPLETED FEATURES AND DELIVERABLES
  // ==========================================
  createHeading1('4. Completed Features and Deliverables'),
  createParagraph(
    'During Week 02 of the Stack & Scale Remote Internship 2026, all core milestones and technical deliverables established in the project specification were successfully engineered, rigorously verified, and handed over:'
  ),

  createHeading2('4.1 Executive Financial Dashboard & Balance Tracking'),
  createBullet('Real-time net balance hero card dynamically calculated from lifetime income minus lifetime expenses in minor currency units.', '• Net Balance Hero Card:'),
  createBullet('Monthly cash flow summary cards tracking active monthly income and expenses with distinctive emerald green and rose red accent badges.', '• Monthly Cash Flow:'),
  createBullet('Monthly remaining budget card displaying real-time safe-to-spend allowance derived across all configured category budgets.', '• Safe-to-Spend Allowance:'),
  createBullet('Recent transactions quick ledger showcasing the latest transactions with category icons, color tags, and formatted PKR values.', '• Recent Activity Stream:'),

  createHeading2('4.2 Comprehensive Transaction Management & Input Validation'),
  createBullet('Dual-type transaction creation supporting both Income and Expense flows with dynamic type toggles.', '• Dual-Type Logging:'),
  createBullet('Dynamic category selector chips mapped to predefined color tokens and Material icons for instant recognition.', '• Category Chips:'),
  createBullet('Full transaction CRUD: Create, Read, Update, and Delete operations backed by atomic database transactions.', '• Full CRUD Lifecycle:'),
  createBullet('Rigorous defensive form validation: blocks empty inputs, rejects non-numeric or negative values, enforces a PKR 100 Million ceiling, and prevents double-submission.', '• Defensive Validation:'),

  createHeading2('4.3 Monthly Budget Management & Real-Time Alert Engine'),
  createBullet('Category spending cap allocation per calendar month with relational unique constraints preventing duplicate allocations.', '• Category Spending Caps:'),
  createBullet('Real-time threshold calculations: On Track (<80%), Near Limit Warning (80%–99%), and Over-Budget Danger (≥100%).', '• Threshold Indicators:'),
  createBullet('High-visibility warning indicators: Amber alert pills and prominent red Over-Budget alert banners.', '• Dynamic Alert Cards:'),
  createBullet('Cross-controller reactivity: Logging or updating a transaction immediately recalculates budget progress without page reloads.', '• Cross-Screen Sync:'),

  createHeading2('4.4 Multi-Axis Historical Ledger & Proportional Spending Analytics'),
  createBullet('Calendar month navigation pills allowing rapid traversal between historical, active, and future months.', '• Month Traversal:'),
  createBullet('Horizontal scrollable category filter bar with quick single-tap isolation and clear-filter shortcuts.', '• Category Isolation:'),
  createBullet('Ranked horizontal progress bars visualizing exact category percentage shares sorted by highest expense first.', '• Proportional Breakdown:'),
  createBullet('Zero-division safeguards guaranteeing stable rendering for months with zero recorded expenditures.', '• Zero-Division Guard:'),

  createHeading2('4.5 Local Relational Persistence & Quality Assurance Deliverables'),
  createBullet('100% offline-first relational database architecture with foreign key enforcement and category pre-seeding.', '• Relational Database:'),
  createBullet('Settings diagnostic tool reporting live table row counts, database path, and storage metrics.', '• Storage Diagnostics:'),
  createBullet('Automated test suite of 37 unit, model, and database tests passing with 100% success rate.', '• Automated Test Suite:'),
  createBullet('Clean static analysis verification with zero errors, warnings, or linter suggestions.', '• Static Code Quality:'),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 5: BRIEF EXPLANATION OF MAIN PROJECT FLOW, SCREENS, FUNCTIONS & POINTS
  // ==========================================
  createHeading1('5. Project Architecture, Screens, Functions, and Key Points'),
  createParagraph(
    'This section details the operational architecture of SpendWise, walking through the end-to-end user journey, the primary application screens, key engineering functions, and fundamental architectural principles.'
  ),

  createHeading2('5.1 Main Project Flow'),
  createParagraph(
    'The SpendWise user journey follows a closed-loop five-step financial discipline workflow:'
  ),
  createBullet('Step 1 — Launch & Balance Check: The user launches the application to instantly view net balance, active monthly income/expenses, and remaining budget capacity on the Executive Dashboard.', '1. Financial Check-in:'),
  createBullet('Step 2 — Fast Transaction Logging: The user taps the center Quick-Add button in the bottom navigation bar to record an income or expense with category chips, amount, and date.', '2. Transaction Capture:'),
  createBullet('Step 3 — Reactive Ledger Update: The transaction is persisted to the local database, immediately updating the net balance hero card and the recent transaction feed.', '3. Instant Ledger Update:'),
  createBullet('Step 4 — Budget Threshold Evaluation: The budget engine checks the transaction category against monthly spending caps, dynamically updating progress bars and triggering warning pills if threshold limits are approached.', '4. Threshold Monitoring:'),
  createBullet('Step 5 — Historical Audit & Analytics: The user visits the History tab to review multi-axis filtered expenditures and inspect proportional spending distribution bars.', '5. Audit & Analytics:'),

  createHeading2('5.2 Primary Application Screens'),
  createBullet('Executive Dashboard: Serves as the primary operational cockpit, presenting the hero net balance card, monthly cash flow cards, remaining safe-to-spend allowance, and recent transaction list.', '• Dashboard Screen:'),
  createBullet('Transaction History Screen: Displays the full chronological ledger with calendar month selector pills, horizontal category filter chips, search query input, and category spending breakdown view.', '• History Screen:'),
  createBullet('Add/Edit Transaction Screen: Provides an intuitive form interface with Income/Expense type toggles, minor-unit amount parsing, interactive date pickers, dynamic category chips, and notes.', '• Transaction Form:'),
  createBullet('Monthly Budgets Screen: Shows total monthly budget pool progress alongside individual category budget cards featuring real-time warning pills (80%) and over-budget badges (100%).', '• Budgets Screen:'),
  createBullet('System Settings Screen: Displays application build metadata, theme configuration, and real-time database storage diagnostics including table row counts.', '• Settings Screen:'),

  createHeading2('5.3 Core Engineering Functions'),
  createBullet('Integer Minor Currency Arithmetic: Storing monetary amounts strictly as 64-bit integer paisas (1 PKR = 100 Paisa) guarantees mathematical exactness across all balances and budget comparisons.', '• Minor-Unit Engine:'),
  createBullet('Parameterized Relational Queries: All SQLite operations utilize parameter substitution to protect against SQL syntax injection and maintain relational integrity across categories and budgets.', '• Parameterized CRUD:'),
  createBullet('Dynamic Threshold Classifier: Computes expenditure-to-limit ratios in real-time, categorizing budgets into On Track (<80%), Near Limit (80%–99%), and Over Budget (≥100%).', '• Threshold Classifier:'),
  createBullet('Cross-Controller Synchronization: Built on native change notification mechanics, ensuring that modifying a transaction instantly triggers recalculations across the dashboard and budget tabs.', '• Cross-Module Sync:'),

  createHeading2('5.4 Important Project Points & Guarantees'),
  createBullet('100% Local & Offline: Operates with zero network dependency, zero cloud logins, and zero external tracking telemetry.', '• Air-Gapped Privacy:'),
  createBullet('Persistent Tab Navigation: Built on an IndexedStack scaffold that preserves tab scroll positions and form state across transitions.', '• State Preservation:'),
  createBullet('Strict Defensive Validation: Prevents duplicate submissions and rejects negative or zero monetary inputs.', '• Input Defense:'),

  new Paragraph({
    children: [new PageBreak()],
  }),

  // ==========================================
  // SECTION 6: WEEKLY LEARNING OUTCOMES
  // ==========================================
  createHeading1('6. Weekly Learning Outcomes'),
  createParagraph(
    'Developing SpendWise throughout Week 02 of the Stack & Scale Remote Internship 2026 provided comprehensive exposure to production-grade mobile engineering, fintech software architecture, and automated verification. The primary competencies acquired include:'
  ),

  createBullet(
    'Engineered a complete Material 3 design system featuring signature brand tokens (#6536C7), responsive card surfaces, elevation hierarchies, and layout constraints that guarantee zero pixel overflows across compact mobile screens.',
    '1. Advanced Fintech UI/UX Systems:'
  ),
  createBullet(
    'Gained end-to-end expertise in relational SQLite lifecycle management, foreign key cascade enforcement, schema evolution, and atomic database transactions that maintain referential integrity.',
    '2. Embedded Relational Database Architecture:'
  ),
  createBullet(
    'Implemented the industry-standard integer minor currency units standard (storing paisas) to eliminate floating-point precision loss across running balances, budget comparisons, and audit ledgers.',
    '3. Precision Financial Arithmetic:'
  ),
  createBullet(
    'Designed multi-level defensive input pipelines incorporating double-submission prevention, type-safe currency parsing, boundary validation, and clear user error feedback.',
    '4. Defensive Form Validation & UX:'
  ),
  createBullet(
    'Constructed maintainable, clean reactive state architectures using native Flutter ChangeNotifiers, achieving snappy 60fps UI updates and cross-screen synchronization without third-party library bloat.',
    '5. Reactive State Architecture:'
  ),
  createBullet(
    'Engineered multi-axis querying combining month-year keys with dynamic category chips, and implemented ranked horizontal progress visualizations with explicit zero-division safeguards.',
    '6. Multi-Axis Data Querying & Analytics:'
  ),
  createBullet(
    'Cultivated rigorous testing habits by authoring 37 automated unit, widget, and database tests, ensuring 100% test pass rates and zero regressions across all milestone deliverables.',
    '7. Automated Verification & Quality Assurance:'
  ),

  new Paragraph({ spacing: { before: 140, after: 30 } }),
  createCallout(
    'Final Internship Evaluation Sign-off',
    'Report authored by Nida Fatima for Stack & Scale Remote Internship 2026 — Week 02. All six required sections, authentic screenshots (Days 1–5 and Final Output), functional deliverables, and learning outcomes have been verified for official submission.'
  ),
];

// Document Definition
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
                      width: { size: 55, type: WidthType.PERCENTAGE },
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
                              text: 'SpendWise — Week 02 Weekly Submission',
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
                      width: { size: 45, type: WidthType.PERCENTAGE },
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
                              text: 'Stack & Scale Internship 2026',
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
                              text: 'Developer: Nida Fatima',
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
                              text: 'Official Submission',
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

// Write to documentation/SpendWise_Week02_Weekly_Submission.docx
const outputPath = path.resolve('documentation/SpendWise_Week02_Weekly_Submission.docx');

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(outputPath, buffer);
  console.log('SUCCESS: Generated Microsoft Word Weekly Submission Document:');
  console.log('Path:', outputPath);
  console.log('Size:', (buffer.length / 1024 / 1024).toFixed(2), 'MB');
}).catch(err => {
  console.error('ERROR generating Weekly Submission document:', err);
  process.exit(1);
});
