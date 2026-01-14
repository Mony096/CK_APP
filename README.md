# biz_travel

A new Flutter project.

## Structure

The app is organized around feature modules with shared core and app-level
layers to keep domain code isolated and reusable.

- `lib/main.dart`: application entry point and provider wiring.
- `lib/app/`: app-level concerns (lifecycle, notifications, wrapper navigation).
- `lib/core/`: cross-cutting infrastructure (networking, storage, errors, utils).
- `lib/features/`: domain modules (auth, service, customer, equipment, etc.),
  usually split into `presentation/` and `providers/`.
- `lib/shared/`: reusable UI primitives (dialogs, widgets).
- `lib/legacy/`: legacy flows/utilities kept in the project.
- `lib/screens/`, `lib/component/`, `lib/form/`, `lib/helper/`,
  `lib/middleware/`, `lib/utilities/`, `lib/dashboard/`, `lib/constant/`:
  additional app-specific modules.

## Project Structure

```
.
├─ android/ ios/ linux/ macos/ web/ windows/   # platform projects
├─ assets/                                     # bundled assets (see pubspec.yaml)
├─ images/                                     # image resources
├─ lib/                                        # application source
│  ├─ main.dart
│  ├─ app/
│  ├─ core/
│  ├─ features/
│  ├─ shared/
│  ├─ legacy/
│  ├─ screens/
│  ├─ component/
│  ├─ form/
│  ├─ helper/
│  ├─ middleware/
│  ├─ utilities/
│  ├─ dashboard/
│  └─ constant/
├─ pubspec.yaml                                # dependencies + assets
├─ analysis_options.yaml                       # lint rules
└─ README.md
```

Generated folders like `.dart_tool/` and `build/` are omitted from the tree.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
