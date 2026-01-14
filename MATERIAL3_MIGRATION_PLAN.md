# Material Design 3 Migration Plan

## Overview

This document provides a step-by-step plan for gradually migrating the BizD Tech Service app to fully utilize Material Design 3 (Material You). The theme infrastructure has been updated; this plan covers the remaining screen-by-screen migration.

## Current State

| Component | Status |
|-----------|--------|
| `app_theme.dart` | ✅ Updated with `ColorScheme.fromSeed()` |
| `app_tokens.dart` | ✅ Enhanced with M3 documentation |
| Screen files | ❌ 1,275+ hardcoded colors in 50 files |
| Navigation | ✅ Already using `NavigationBar` (M3 component) |
| Dialogs | ⚠️ Using M3 theme but with hardcoded colors |

---

## Migration Phases

### Phase 1: High-Impact Screens (Priority: High)

These screens are most visible to users. Migrate first for maximum impact.

#### 1.1 Dashboard (`lib/dashboard/dashboard.dart`)
**Hardcoded colors found:** ~80+ instances
**Key replacements:**

| Hardcoded | Replace With |
|-----------|--------------|
| `Color.fromARGB(255, 66, 83, 100)` | `Theme.of(context).colorScheme.primaryContainer` or `AppColors.legacyAppBarBg` |
| `Colors.green` | `Theme.of(context).colorScheme.primary` |
| `Colors.white` | `Theme.of(context).colorScheme.surface` or `Theme.of(context).colorScheme.onPrimary` |
| `Colors.grey` | `Theme.of(context).colorScheme.outline` |
| `Colors.black87` | `Theme.of(context).colorScheme.onSurface` |
| `Colors.grey.shade300` | `Theme.of(context).colorScheme.outlineVariant` |

**Migration pattern:**
```dart
// BEFORE
Container(
  color: const Color.fromARGB(255, 66, 83, 100),
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)

// AFTER
Container(
  color: Theme.of(context).colorScheme.primaryContainer,
  child: Text('Hello', style: TextStyle(
    color: Theme.of(context).colorScheme.onPrimaryContainer,
  )),
)
```

#### 1.2 Main Screen (`lib/screens/main/main_screen.dart`)
**Status:** Already using M3 `NavigationBar` ✅
**Action:** No changes needed

#### 1.3 Service Screen (`lib/screens/service/service.dart`)
**Hardcoded colors found:** ~15 instances
**Priority replacements:**
- `Colors.green` → `colorScheme.primary`
- `Colors.grey` → `colorScheme.onSurfaceVariant`
- `Colors.white` → `colorScheme.surface`

---

### Phase 2: Dialog System (Priority: High)

The dialog system in `lib/utilities/dialog/dialog.dart` affects all screens.

**Current issues:**
- `backgroundColor: Colors.white` - should use `colorScheme.surface`
- `surfaceTintColor: Colors.white` - should use `colorScheme.surfaceTint`
- Hardcoded button colors

**Migration:**
```dart
// BEFORE
AlertDialog(
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.white,
  // ...
)

// AFTER
AlertDialog(
  // Let theme handle these, or:
  backgroundColor: Theme.of(context).colorScheme.surface,
  // surfaceTintColor is now handled by theme
  // ...
)
```

---

### Phase 3: Component Library (Priority: Medium)

#### 3.1 Custom Components (`lib/component/`)

| File | Hardcoded Count | Priority |
|------|-----------------|----------|
| `DatePicker.dart` | ~25 | Medium |
| `text_field.dart` | ~10 | Medium |
| `text_field_dialog.dart` | ~20 | Medium |
| `text_remark.dart` | ~15 | Medium |
| `DatePickerDialog.dart` | ~20 | Medium |

**Pattern for input components:**
```dart
// BEFORE
fillColor: Colors.white,
border: Border.all(color: Colors.grey),

// AFTER
fillColor: Theme.of(context).colorScheme.surface,
border: Border.all(color: Theme.of(context).colorScheme.outline),
```

#### 3.2 Adaptive Widgets (`lib/core/widgets/`)
**Status:** Already using `AppColors` tokens ✅
**Action:** Minor updates to use `colorScheme` where appropriate

---

### Phase 4: Feature Screens (Priority: Medium)

#### Service Module (`lib/screens/service/`)

| File | Hardcoded Count | Notes |
|------|-----------------|-------|
| `serviceById.dart` | ~60 | Complex screen |
| `openIssue.dart` | ~70 | Many buttons/indicators |
| `materialReserve.dart` | ~55 | Status indicators |
| `serviceCheckList.dart` | ~75 | Checkboxes, status |
| `time.dart` | ~80 | Time pickers |
| `sericeEntry.dart` | ~50 | Form inputs |

#### Equipment Module (`lib/screens/equipment/`)

| File | Hardcoded Count | Notes |
|------|-----------------|-------|
| `equipment_create.dart` | ~15 | Form screen |
| `equipment_list.dart` | ~25 | List with search |
| `equipmentImage.dart` | ~30 | Image gallery |
| `component/general.dart` | ~25 | Component details |
| `component/component.dart` | ~35 | Nested components |
| `select/*.dart` | ~40 each | Selection dialogs |

---

### Phase 5: Auth & Settings (Priority: Low)

| File | Action |
|------|--------|
| `login_screen_v2.dart` | Update to M3 styling |
| `setting.dart` | Minor color updates |
| `ChangePasswordScreen.dart` | Form styling |

---

## Color Mapping Reference

### Primary Actions
| Legacy | Material 3 |
|--------|-----------|
| `Colors.green` | `colorScheme.primary` |
| `Color(0xFF22C55E)` | `colorScheme.primary` |
| `AppColors.primary` | `colorScheme.primary` |

### Surfaces & Backgrounds
| Legacy | Material 3 |
|--------|-----------|
| `Colors.white` | `colorScheme.surface` |
| `Color.fromARGB(255, 255, 255, 255)` | `colorScheme.surface` |
| `AppColors.background` | `colorScheme.surfaceContainerHighest` |
| `Colors.grey[100]` | `colorScheme.surfaceContainerLow` |

### Text Colors
| Legacy | Material 3 |
|--------|-----------|
| `Colors.black` | `colorScheme.onSurface` |
| `Colors.black87` | `colorScheme.onSurface` |
| `Colors.grey` | `colorScheme.onSurfaceVariant` |
| `Colors.white` (on primary) | `colorScheme.onPrimary` |

### Borders & Dividers
| Legacy | Material 3 |
|--------|-----------|
| `Colors.grey.shade300` | `colorScheme.outlineVariant` |
| `Colors.grey.shade400` | `colorScheme.outline` |
| `Colors.black12` | `colorScheme.outlineVariant` |

### Status / Semantic Colors
| Legacy | Material 3 |
|--------|-----------|
| `Colors.red` / `Colors.redAccent` | `colorScheme.error` |
| `Colors.blue` | `colorScheme.tertiary` |
| Keep `AppColors.statusX` | Status colors are business logic |

### Legacy App Bar Color
| Legacy | Material 3 |
|--------|-----------|
| `Color.fromARGB(255, 66, 83, 100)` | `colorScheme.primaryContainer` or create `AppColors.legacyAppBarBg` |

---

## Helper Extension (Optional)

Add this extension for easier migration:

```dart
// lib/core/extensions/theme_extensions.dart
import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Shorthand getters
  Color get primaryColor => colors.primary;
  Color get surfaceColor => colors.surface;
  Color get onSurfaceColor => colors.onSurface;
  Color get errorColor => colors.error;
  Color get outlineColor => colors.outline;
}

// Usage:
// color: context.primaryColor
// color: context.colors.primary
```

---

## Testing Checklist

After migrating each screen:

- [ ] Light mode looks correct
- [ ] Dark mode looks correct (test with `ThemeMode.dark`)
- [ ] Text is readable (contrast ratio)
- [ ] Interactive elements have correct states
- [ ] Status indicators still distinguish properly
- [ ] No visual regressions

---

## Estimated Effort

| Phase | Files | Est. Hours | Priority |
|-------|-------|------------|----------|
| Phase 1: Dashboard | 1 | 2-3 | High |
| Phase 2: Dialogs | 1 | 1-2 | High |
| Phase 3: Components | 7 | 3-4 | Medium |
| Phase 4: Service screens | 8 | 6-8 | Medium |
| Phase 4: Equipment screens | 8 | 4-5 | Medium |
| Phase 5: Auth/Settings | 3 | 1-2 | Low |
| **Total** | **28** | **17-24 hours** | - |

---

## Quick Start Commands

### Find hardcoded colors in a specific file:
```bash
grep -n "Colors\.\|Color\.fromARGB\|Color(0x" lib/dashboard/dashboard.dart
```

### Find all files with hardcoded colors:
```bash
grep -rl "Color\.fromARGB\|Colors\." lib/screens/ | wc -l
```

### Run analysis after changes:
```bash
flutter analyze lib/
```

---

## Dark Mode Testing

To test dark mode, temporarily change in `main.dart`:

```dart
MaterialApp(
  // ...
  themeMode: ThemeMode.dark,  // Force dark mode
  // ...
)
```

Or use system setting by keeping `ThemeMode.system` (current default is `ThemeMode.light`).

---

## Resources

- [Flutter Material 3 Guide](https://docs.flutter.dev/ui/design/material)
- [Material 3 Color System](https://m3.material.io/styles/color/overview)
- [ColorScheme Class](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [Migration Breaking Changes](https://docs.flutter.dev/release/breaking-changes/material-3-migration)
