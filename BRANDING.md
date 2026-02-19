# MoviePeak Branding Changes

This file tracks branding customization done on top of the existing template.

## App Identity

- App/package display name changed to MoviePeak:
  - `pubspec.yaml` (`name: moviepeak_mobile`)
  - `android/app/src/main/AndroidManifest.xml` (`android:label="MoviePeak"`)
  - `ios/Runner/Info.plist` (`CFBundleName`, `CFBundleDisplayName`)

## Typography

- Migrated UI typography to **Manrope** via Google Fonts:
  - `lib/core/theme/app_theme.dart`

## Colors (black + yellow)

- Added brand palette constants:
  - `lib/core/constants/app_colors.dart`
- Applied globally in theme:
  - `lib/core/theme/app_theme.dart`
- Updated Android launcher background + splash background colors:
  - `android/app/src/main/res/values/colors.xml`
  - `android/app/src/main/res/values/ic_launcher_background.xml`

## Icon Placeholder Updates

- Updated Android adaptive icon foreground tint to MoviePeak yellow:
  - `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- Added reusable placeholder icon asset copy:
  - `assets/icons/moviepeak_icon_placeholder.jpg`

## Splash Placeholder Updates

- Updated Android splash to use dark background + centered brand icon vector:
  - `android/app/src/main/res/drawable/launch_background.xml`
  - `android/app/src/main/res/drawable-v21/launch_background.xml`
- Updated iOS launch background to brand black:
  - `ios/Runner/Base.lproj/LaunchScreen.storyboard`

## UI Components Styled to Brand

- Primary CTA button and input/chip styling:
  - `lib/core/theme/app_theme.dart`
  - `lib/core/widgets/primary_button.dart`
- Discovery cards and premium dark surfaces:
  - `lib/core/widgets/movie_poster_card.dart`
  - `lib/core/widgets/empty_state.dart`
  - `lib/core/widgets/loading_card.dart`
