# ZCell Survivor

ZCell Survivor is a native iOS shooting/survival prototype built with SwiftUI and SpriteKit. It is inspired by a cheerful biology-themed mobile shooter layout, but uses original names, code-drawn raster assets, and an offline-only economy.

## Current Build
- SwiftUI menu shell with Battle, Shop, Character, Weapon, and Artifact tabs.
- SpriteKit battle scene with drag movement, auto-shooting, enemy waves, upgrade choices, boss encounter, and run rewards.
- Local progression state using `UserDefaults`.
- Original raster assets in `ZCellSurvivor/Assets.xcassets`.
- No ads, tracking, networking, StoreKit, or real purchases.

## Requirements
- macOS with Xcode installed.
- iOS 17.0 or newer target.
- Swift 6 toolchain through Xcode.

## Run In Xcode
1. Open `ZCellSurvivor.xcodeproj`.
2. Select the `ZCellSurvivor` scheme.
3. Choose an iPhone simulator.
4. Use `Product > Clean Build Folder` if Xcode has stale build output.
5. Press `Cmd + R`.

Tap **Start Battle** on the Battle tab, then drag around the gameplay screen to move. Weapons auto-fire.

## Command-Line Build
For a signing-free device build validation:

```bash
xcodebuild -project ZCellSurvivor.xcodeproj \
  -scheme ZCellSurvivor \
  -configuration Debug \
  -destination generic/platform=iOS \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Project Layout
- `ZCellSurvivor/App`: app entry point and state/data models.
- `ZCellSurvivor/Views`: SwiftUI menus and shared UI components.
- `ZCellSurvivor/Game`: SpriteKit gameplay container and scene.
- `ZCellSurvivor/Assets.xcassets`: app icon and original game art.
- `Tools/GenerateArt.swift`: regenerates the original local PNG asset pack.
- `docs`: implementation plan and session recovery context.

## Regenerate Art Assets
The current assets are checked in. To regenerate them locally:

```bash
swift Tools/GenerateArt.swift
```

## GitHub Notes
- `screenshots/` is intentionally ignored because it contains local reference photos and is not required to build.
- `.build/`, `DerivedData/`, and Xcode user settings are ignored.
- No license has been selected yet; add one before making the repository public if you want explicit reuse terms.
