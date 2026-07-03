# Build Prompt: Full-Featured Modern Android POS System (Flutter + Supabase)

Build a complete, production-ready, modern Point of Sale (POS) mobile app for Android using **Flutter** and **Supabase** as the backend (database, auth, storage, realtime). The final output must be buildable into an installable `.apk` via `flutter build apk --release`.

## Tech Stack
- Flutter (stable channel, latest), Dart null-safety, Material 3
- `supabase_flutter` for auth + database + realtime + storage (product images, receipts)
- `riverpod` (or `provider`) for state management
- `go_router` for navigation
- `intl` for currency/date/number formatting
- `mobile_scanner` (or `flutter_barcode_scanner`) for camera barcode/QR scanning
- `printing` / `esc_pos_utils` + `esc_pos_bluetooth` for receipt printing (Bluetooth thermal printers)
- `pdf` package for generating PDF receipts/invoices/reports
- `fl_chart` for sales dashboards/reports
- `connectivity_plus` + local caching (`sqflite` or `hive`) for offline support
- `share_plus` for sharing receipts/reports

## Supabase Schema (expand beyond a basic schema)
- **organizations** (id, name, timezone, currency, tax_rate_default) — supports multi-store from day one
- **stores** (id, organization_id FK, name, address, phone)
- **profiles** (id uuid PK references auth.users, full_name, role: owner/admin/manager/cashier, store_id FK, pin_code hash for quick till login, is_active)
- **categories** (id, store_id, name, sort_order)
- **products** (id, store_id, name, sku, barcode, category_id FK, price, cost, tax_rate, stock_qty, low_stock_threshold, unit (each/kg/etc), image_url, is_active, has_variants)
- **product_variants** (id, product_id FK, name e.g. "Size: L", price_delta, sku, stock_qty) — for size/color/etc.
- **modifiers** (id, name) and **product_modifiers** (product_id, modifier_id, price_delta) — e.g. "extra cheese", "no ice"
- **suppliers** (id, name, phone, email)
- **purchase_orders** (id, supplier_id FK, status, created_at) + **purchase_order_items** (product_id, qty, unit_cost) — for restocking workflow
- **customers** (id, name, phone, email, loyalty_points, total_spent)
- **discounts** (id, name, type: percent/flat, value, applies_to: cart/product/category, min_purchase, active_from, active_to)
- **shifts** (id, cashier_id FK, store_id FK, opening_float, closing_float, opened_at, closed_at, status: open/closed) — cash drawer session tracking
- **sales** (id, store_id, shift_id FK, cashier_id FK, customer_id FK, subtotal, discount_total, tax_total, total, payment_method: cash/card/mobile_wallet/split, amount_tendered, change_due, status: completed/refunded/voided/held, receipt_number, created_at)
- **sale_items** (id, sale_id FK, product_id FK, variant_id FK nullable, product_name snapshot, unit_price, quantity, modifiers_snapshot jsonb, discount_applied, line_total)
- **sale_payments** (id, sale_id FK, method, amount) — supports split payments (part cash, part card)
- **stock_movements** (id, product_id FK, change_qty, reason: sale/restock/adjustment/refund/transfer, reference_id, created_by, created_at)
- **loyalty_transactions** (id, customer_id FK, points_change, reason, sale_id FK)
- **audit_log** (id, user_id, action, table_name, record_id, created_at) — traceability for sensitive actions (voids, refunds, price overrides)

Include:
- Triggers to auto-decrement stock and log `stock_movements` on `sale_items` insert, and reverse on refund/void.
- Trigger to auto-create `profiles` on new `auth.users` signup.
- Trigger/function to auto-generate sequential, store-scoped `receipt_number`.
- Row Level Security scoped by `store_id`/`organization_id` so staff only see their own store's data; `owner`/`admin` roles can see across stores in their organization.
- Seed data: one sample organization, one store, a few categories/products, and a demo admin user.

## Feature Set (this is the core of the app — implement all of it)

### 1. Authentication & Multi-User Access
- Full email/password login + signup.
- Fast PIN-code login for switching cashiers mid-shift without full logout.
- Role-based access control: Owner, Admin, Manager, Cashier — each sees a different subset of menu items and permissions (e.g. only Manager+ can apply discounts over X%, issue refunds, edit prices).
- Multi-store support: users tied to a store, owners/admins can switch between stores.

### 2. Till / Shift Management
- "Open till" at start of shift: enter opening cash float.
- "Close till" at end of shift: count cash, system shows expected vs counted, flags discrepancies.
- Shift summary report (total sales, cash/card breakdown, refunds, discounts given).

### 3. POS / Checkout Screen (core screen, must be fast)
- Product grid with images, search, category filter chips, and barcode scan button (camera-based scanning via `mobile_scanner`).
- Support product variants (size/color) and modifiers (add-ons, "no onions" style notes) via a selection sheet when tapping a product.
- Cart with quantity steppers, per-line discounts, remove/void line item (with reason + manager approval if configured).
- "Hold sale" / park a cart and recall it later (for multitasking with multiple customers).
- Apply cart-level discounts (manual % / flat, or auto-applied promo codes from the `discounts` table).
- Tax calculation per item (supports different tax rates per product) and a cart total.
- Multiple payment methods per sale (split payment): cash, card, mobile wallet — record each in `sale_payments`.
- Cash payment: numeric keypad for amount tendered, auto change calculation, quick-cash buttons (exact, $10, $20, $50...).
- Customer lookup/attach to sale (for loyalty points and purchase history), or quick "walk-in" checkout with no customer.
- Complete sale → generates a receipt.

### 4. Receipts
- On-screen receipt after checkout with itemized breakdown.
- Print to Bluetooth thermal receipt printer (ESC/POS).
- Generate PDF receipt and share via email/WhatsApp/etc. (`share_plus`).
- Reprint any past receipt from Sales History.

### 5. Inventory & Product Management
- Full CRUD for products, variants, modifiers, and categories, with image upload to Supabase Storage.
- Barcode scanning to quickly find/add a product while managing inventory.
- Stock adjustment screen (restock, damage/loss write-off, manual correction) — all logged to `stock_movements`.
- Low-stock and out-of-stock views/alerts.
- Purchase order workflow: create a PO to a supplier, mark items received, auto-increase stock.
- Bulk import/export of products via CSV.

### 6. Customers & Loyalty
- Customer directory with search, add/edit, purchase history per customer.
- Loyalty points: earn on purchase, redeem toward a sale, configurable earn rate.
- Customer-facing purchase totals ("total spent", "visits") for basic CRM insight.

### 7. Discounts & Promotions
- Manager-configurable discount rules (percentage/flat, product/category/cart-wide, date-limited, min purchase threshold).
- Promo code entry at checkout.

### 8. Sales History, Refunds & Voids
- Searchable/filterable list of past sales (date range, cashier, store, payment method, status).
- Full refund or partial (line-item) refund, with reason capture and automatic stock reversal.
- Void a sale (before it's finalized/settled) with manager PIN approval.
- Every void/refund/price-override writes to `audit_log`.

### 9. Reporting & Analytics Dashboard
- Daily/weekly/monthly sales summary: revenue, transaction count, average basket size.
- Best-selling products / slow movers.
- Sales by category, by cashier, by payment method (charts via `fl_chart`).
- Profit margin report (using `cost` vs `price`).
- Exportable PDF/CSV reports.

### 10. Offline Mode & Sync
- Cache product catalog locally (`sqflite`/`hive`) so the POS screen works without connectivity.
- Queue sales made while offline and sync to Supabase when connection returns; show a "pending sync" indicator.
- Conflict-safe stock reconciliation on reconnect.

### 11. Hardware Integration
- Bluetooth thermal receipt printer support.
- Barcode/QR scanning via device camera (and optionally external Bluetooth scanner as keyboard-wedge input).
- Optional: cash drawer trigger via printer's cash-drawer-kick command.

### 12. Settings & Administration
- Store profile (name, address, logo, receipt footer message, default tax rate, currency).
- Staff management: invite/create staff, assign roles, deactivate accounts, reset PINs.
- Tax rate configuration (single or multi-rate).
- Backup/export of full data as CSV.
- App theme (light/dark) and language toggle (structure the UI for future i18n via `intl`, even if only English strings are populated initially).

### 13. Notifications
- In-app low-stock alerts.
- Shift-close reminder if a till has been open unusually long.

## Non-functional requirements
- Fast, large-tap-target UI optimized for a phone or tablet at a checkout counter; core "add to cart → charge → done" flow should take as few taps as possible.
- Graceful loading/error/empty states everywhere.
- All monetary values handled as integers (cents) or `Decimal` internally to avoid floating-point rounding errors, formatted for display via `intl`.
- Sensitive actions (void, refund, discount above threshold, price edit) require manager PIN confirmation.
- Proper Flutter project structure: `lib/main.dart`, `lib/models/`, `lib/services/` (Supabase + local DB + printer services), `lib/providers/` (state), `lib/screens/`, `lib/widgets/`, `lib/utils/`.

## Deliverables
1. Full Flutter project source implementing all features above, organized in a clean, scalable folder structure.
2. `supabase/schema.sql` with the complete schema, triggers, functions, RLS policies, and seed data, ready to paste into the Supabase SQL Editor.
3. README covering:
   - Supabase project setup and running the schema.
   - Where to configure the Supabase URL/anon key and any printer/scanner permissions in `AndroidManifest.xml`.
   - Local dev run (`flutter pub get`, `flutter run`).
   - Producing the release APK (`flutter build apk --release`) and the output path.
   - A short feature checklist mapping each feature above to the screen/file that implements it.