You are a senior Flutter engineer (2026 best practices). Build a production-ready Flutter app foundation for a “Sales Order” mobile app that feels native on both Android and iOS WITHOUT Swift/Kotlin.

Goals:
- One codebase Flutter.
- Android uses Material 3 (native Android feel).
- iOS uses adaptive Cupertino for key native moments (date/time pickers, action sheets, modal presentation, navigation feel where needed).
- Add an iOS “glass” visual layer (frosted blur + translucency) for headers/bottom sheets/nav surfaces using BackdropFilter, without requiring official “Liquid Glass” widgets.
- Avoid maintaining two separate UI code paths; implement small platform-adaptive widgets.
- Include light/dark theme, design tokens (colors, radius, spacing, typography) similar to shadcn’s neutral look.
- Architecture: go_router for navigation, Riverpod for state management (or choose one and be consistent), clean folder structure, and example screens: Sales Order List, Sales Order Detail, Create/Edit Sales Order.

Deliverables:
1) pubspec.yaml dependencies list.
2) Folder structure (lib/…) with brief purpose.
3) Theme setup:
   - Material 3 ThemeData with neutral palette, subtle borders, low elevation, consistent radius.
   - CupertinoThemeData for iOS overlays.
4) Platform-adaptive components:
   - AdaptiveScaffold (Material Scaffold on Android, CupertinoPageScaffold on iOS if appropriate)
   - AdaptiveDialog (Material AlertDialog vs CupertinoAlertDialog)
   - AdaptiveActionSheet (showModalBottomSheet vs CupertinoActionSheet)
   - AdaptiveDatePicker (showDatePicker vs CupertinoDatePicker)
5) “Glass” components:
   - GlassAppBar / GlassContainer / GlassBottomSheetSurface using BackdropFilter + ClipRRect + Opacity.
   - Should be safe for performance: blur only on small surfaces, avoid blurring full-screen continuously.
6) Example UI:
   - SalesOrderListScreen with list items, search/filter UI.
   - SalesOrderDetailScreen with sections + actions (Edit, Approve, Cancel).
   - SalesOrderEditScreen with form fields (Customer, Date, Items) using adaptive pickers and dialogs.
7) Code should compile and run, with clear comments and no placeholders like “TODO implement”.

Constraints:
- Do not use Swift/Kotlin.
- Do not use Cupertino everywhere (bad on Android).
- Keep code clean, minimal, and scalable.
- Provide full Dart code for the key files and show how to wire routing + state + theming.

Return:
- Step-by-step setup instructions.
- The exact contents of each Dart file (main.dart, router.dart, theme.dart, adaptive widgets, glass widgets, and the 3 example screens).
