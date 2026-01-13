# Implementation Plan: Architecture Improvements

## Overview
This plan addresses all architectural issues identified in the code review for the `bizd_tech_service` Flutter app.

---

## Phase 1: Critical Fixes ⏱️ ~15 min

### Task 1.1: Fix SSL Security
- [ ] Update `main.dart` to only disable SSL in debug mode
- [ ] Add `kDebugMode` check before overriding HTTP

### Task 1.2: Fix Broken File Names
- [ ] Remove `lib/component/title_break copy.dart`
- [ ] Rename `lib/appLifecycleTracker .dart` → `lib/app_lifecycle_tracker.dart`
- [ ] Rename `lib/RingtoneController .dart` → `lib/ringtone_controller.dart`
- [ ] Update all imports referencing renamed files

---

## Phase 2: Code Organization ⏱️ ~30 min

### Task 2.1: Create App Initializer
- [ ] Create `lib/core/app_initializer.dart`
- [ ] Move Firebase init logic from `main.dart`
- [ ] Move Hive init logic from `main.dart`
- [ ] Move Notification init logic from `main.dart`
- [ ] Simplify `main.dart` to use `AppInitializer`

### Task 2.2: Create Environment Configuration
- [ ] Create `lib/core/config/environment.dart`
- [ ] Define dev/staging/prod environments
- [ ] Move hardcoded URLs from `DioClient` to config
- [ ] Update `DioClient` to use environment config

---

## Phase 3: Folder Restructure ⏱️ ~45 min

### Task 3.1: Rename Middleware to Auth Screens
- [ ] Rename `lib/middleware/` → `lib/screens/auth/`
- [ ] Update all imports

### Task 3.2: Create Feature-Based Structure
- [ ] Create `lib/features/` directory
- [ ] Move service-related files to `lib/features/service/`
- [ ] Move equipment-related files to `lib/features/equipment/`
- [ ] Update all imports

---

## Phase 4: Repository Layer ⏱️ ~1 hour (Future)

### Task 4.1: Create Base Repository Interface
- [ ] Create `lib/core/repository/base_repository.dart`

### Task 4.2: Implement Service Repository
- [ ] Create `lib/features/service/repository/service_repository.dart`
- [ ] Refactor `ServiceListProviderOffline` to use repository

---

## Execution Order

1. **Phase 1** - Critical fixes (security, broken files)
2. **Phase 2** - Code organization (initializer, config)
3. **Phase 3** - Folder restructure (if time permits)
4. **Phase 4** - Repository layer (future enhancement)

---

## Status: ✅ Phase 1 & 2 Completed

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1 | ✅ Done | SSL security, file cleanup |
| Phase 2 | ✅ Done | AppInitializer, Environment config |
| Phase 3 | ⚪ Pending | Folder restructure (optional) |
| Phase 4 | ⚪ Future | Repository layer |

### Commit: `0d520f3`
- 19 files changed
- 561 insertions, 250 deletions
