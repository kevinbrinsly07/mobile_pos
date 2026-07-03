# Modern Android POS (Flutter + Supabase)

Production-oriented mobile POS scaffold for Android with:
- Supabase auth/database/realtime/storage backend
- Flutter Material 3 UI optimized for checkout workflow
- Riverpod state management + go_router navigation
- Inventory, shifts/till, sales history/refunds, reports, staff/settings modules
- Offline sale queue (Hive), barcode scanner, PDF/print/share integrations

## 1) Supabase Setup

1. Create a Supabase project.
2. Open SQL Editor and run [supabase/schema.sql](supabase/schema.sql).
3. In Supabase Authentication, create at least one user (email/password).
4. Promote that user to admin using the SQL comment block at the bottom of [supabase/schema.sql](supabase/schema.sql).

## 2) Configure App Secrets

Use dart defines when running/building:

```bash
flutter run \
	--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

The values are consumed in [lib/utils/app_config.dart](lib/utils/app_config.dart).

## 3) Android Permissions

Configured in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):
- internet/network
- camera (barcode scanning)
- bluetooth + bluetooth connect/scan (thermal printer)

## 4) Local Development

```bash
flutter pub get
flutter run \
	--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## 5) Build Release APK

```bash
flutter build apk --release \
	--dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Output path:
- build/app/outputs/flutter-apk/app-release.apk

## 6) Feature Checklist -> Implementation Map

- Auth (email/password + PIN): [lib/screens/login_screen.dart](lib/screens/login_screen.dart), [lib/screens/pin_login_screen.dart](lib/screens/pin_login_screen.dart), [lib/services/auth_service.dart](lib/services/auth_service.dart)
- Roles + gated staff access: [lib/utils/role_permissions.dart](lib/utils/role_permissions.dart), [lib/screens/shell_screen.dart](lib/screens/shell_screen.dart)
- Till / shift open-close: [lib/screens/shifts_screen.dart](lib/screens/shifts_screen.dart), [lib/providers/shift_provider.dart](lib/providers/shift_provider.dart)
- POS checkout + split payment + barcode scan: [lib/screens/pos_screen.dart](lib/screens/pos_screen.dart), [lib/providers/pos_provider.dart](lib/providers/pos_provider.dart), [lib/widgets/payment_sheet.dart](lib/widgets/payment_sheet.dart)
- Hold/offline sync pipeline: [lib/services/pos_service.dart](lib/services/pos_service.dart), [lib/services/offline_queue_service.dart](lib/services/offline_queue_service.dart)
- Inventory CRUD/CSV export basics: [lib/screens/inventory_screen.dart](lib/screens/inventory_screen.dart), [lib/services/inventory_service.dart](lib/services/inventory_service.dart)
- Customers + loyalty storage model: [lib/screens/customers_screen.dart](lib/screens/customers_screen.dart), [supabase/schema.sql](supabase/schema.sql)
- Sales history + refund trigger path: [lib/screens/sales_history_screen.dart](lib/screens/sales_history_screen.dart), [supabase/schema.sql](supabase/schema.sql)
- Reports + charts: [lib/screens/reports_screen.dart](lib/screens/reports_screen.dart), [lib/services/report_service.dart](lib/services/report_service.dart)
- Receipt PDF/print/share hooks: [lib/services/receipt_service.dart](lib/services/receipt_service.dart), [lib/services/printer_service.dart](lib/services/printer_service.dart), [lib/screens/inventory_screen.dart](lib/screens/inventory_screen.dart)
- Full backend schema/triggers/RLS/seed: [supabase/schema.sql](supabase/schema.sql)

## Notes

- Monetary values are modeled as integer cents in app models and SQL.
- This scaffold is production-leaning and extensible; complete business rules (manager PIN enforcement rules, advanced promotion engine, and richer receipt templates) are implemented with baseline hooks and can be tightened to your exact store policy.
