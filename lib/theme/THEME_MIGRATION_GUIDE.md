# Dark Mode Theme Migration Guide

This guide documents the pattern for replacing hardcoded colors with theme-aware colors.

## Color Replacement Patterns

### Background Colors
```dart
// Before
backgroundColor: Colors.white
color: Colors.white

// After
backgroundColor: Theme.of(context).colorScheme.surface
color: Theme.of(context).colorScheme.surface
scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor
```

### Text Colors
```dart
// Before
color: Colors.black
color: Colors.black87
color: Colors.grey.shade600

// After
color: Theme.of(context).colorScheme.onSurface
color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)
color: context.appColors.mutedText
```

### Primary/Accent Colors
```dart
// Before
color: Colors.red
backgroundColor: Colors.red

// After
color: Theme.of(context).colorScheme.primary
backgroundColor: Theme.of(context).colorScheme.primary
foregroundColor: Theme.of(context).colorScheme.onPrimary
```

### Error/Danger Colors
```dart
// Before
color: Colors.red

// After (for errors/warnings)
color: Theme.of(context).colorScheme.error
color: context.appColors.danger
```

### Borders/Dividers
```dart
// Before
border: Border.all(color: Colors.grey.shade300)
color: Colors.grey.shade200

// After
border: Border.all(color: Theme.of(context).dividerColor)
color: Theme.of(context).dividerColor
color: context.appColors.border
```

### Shadows/Barriers
```dart
// Before
barrierColor: Colors.black.withOpacity(0.4)
color: Colors.black.withOpacity(0.1)

// After
barrierColor: Theme.of(context).colorScheme.shadow.withOpacity(0.4)
color: Theme.of(context).colorScheme.shadow.withOpacity(0.1)
```

## Using AppColors Extension

The `AppColors` extension provides semantic color tokens:

```dart
// Import
import '../theme/app_theme.dart';

// Usage
final appColors = context.appColors;
appColors.surfaceElevated  // Elevated surfaces
appColors.border           // Borders
appColors.mutedText        // Secondary text
appColors.danger           // Error/danger states
appColors.dangerText       // Error text
```

## Modal Bottom Sheets

Always use theme-aware colors for modals:

```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  barrierColor: Theme.of(context).colorScheme.shadow.withOpacity(0.4),
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    // ... content
  ),
);
```

## Common Widget Patterns

### Buttons
```dart
ElevatedButton.styleFrom(
  backgroundColor: Theme.of(context).colorScheme.primary,
  foregroundColor: Theme.of(context).colorScheme.onPrimary,
)

OutlinedButton.styleFrom(
  foregroundColor: Theme.of(context).colorScheme.primary,
)
```

### Cards/Containers
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    border: Border.all(color: Theme.of(context).dividerColor),
  ),
)
```

### Icons
```dart
Icon(
  Icons.check,
  color: Theme.of(context).colorScheme.primary,
)
```

## Files That Need Migration

Remaining files to update (check with `grep -r "Colors\." lib/`):

1. `lib/features/routines/screens/routine_list_screen.dart` - 36 usages
2. `lib/features/routines/screens/routine_bottom_sheet.dart`
3. `lib/features/routines/screens/routine_edit_screen.dart`
4. `lib/features/routines/screens/routine_detail_screen.dart`
5. `lib/features/routines/screens/routine_preview_sheet.dart`
6. `lib/features/workout/screens/workout_screen.dart`
7. `lib/features/workout/screens/workout_finished_screen.dart`
8. `lib/features/membership/screens/membership_screen.dart`
9. `lib/ui/glass/liquid_glass_pill_navbar.dart`
10. `lib/ui/glass/glass_container.dart`
11. Other utility/widget files

## Testing Checklist

After migration, verify:
- [ ] Light mode displays correctly
- [ ] Dark mode displays correctly
- [ ] System theme mode works
- [ ] All text is readable (good contrast)
- [ ] Modals/sheets respect theme
- [ ] No white-on-white or black-on-black text
- [ ] Borders/dividers are visible
- [ ] Interactive elements are clearly visible

