---
name: zcell-survivor-ios
description: Use when working on the ZCell Survivor native iOS game prototype in this repository, including SwiftUI menus, SpriteKit gameplay, offline progression, original raster art assets, Xcode builds, and GitHub-ready maintenance.
---

# ZCell Survivor iOS Project Skill

## Mission
Work on `ZCell Survivor`, a native Swift iOS shooting/survival prototype inspired by cheerful biology-themed mobile shooter screens. Keep the project original: do not copy protected game names, art, exact UI assets, monetization patterns, or screenshot content.

## Project Shape
- `ZCellSurvivor.xcodeproj`: Xcode project.
- `ZCellSurvivor/App`: app entry point and state/data models.
- `ZCellSurvivor/Views`: SwiftUI menu shell and shared UI.
- `ZCellSurvivor/Game`: SpriteKit run container and gameplay scene.
- `ZCellSurvivor/Assets.xcassets`: checked-in original raster assets.
- `Tools/GenerateArt.swift`: deterministic AppKit script that regenerates local PNG art assets.
- `docs/ios-app-plan.md`: product/implementation plan.
- `docs/session-context.md`: concise handoff context.
- `screenshots/`: local ignored reference photos; do not depend on them for builds.

## Product Direction
- V1 is a playable slice, not a full clone.
- SwiftUI owns menus: Battle, Shop, Character, Weapon, Artifact, shared top currency bar, bottom tab bar, and overlays.
- SpriteKit owns real-time gameplay: drag movement, auto-fire, enemies, projectiles, collisions, damage numbers, upgrades, boss, victory/defeat.
- Economy is offline only: `UserDefaults`, fake coins/gems/stamina/tickets, no StoreKit, no ads, no tracking, no backend.
- Visual direction: colorful biology shooter with original hero/enemy/capsule/chest/currency art.

## Engineering Rules
- Prefer small, targeted changes that preserve the current SwiftUI + SpriteKit split.
- Keep Swift 6 concurrency clean:
  - `GameState` is `@MainActor`.
  - `RunCoordinator` is `@MainActor`.
  - `GameScene` is `@MainActor`.
  - Data crossing UI/game boundaries should remain value types and `Sendable` where practical.
- Route persistent state mutations through `GameState` methods so changes save consistently.
- Do not introduce network, analytics, ads, or real payments unless explicitly requested.
- Do not commit `.build/`, `DerivedData/`, Xcode user data, `.DS_Store`, or `screenshots/`.
- Preserve original raster assets unless replacing them intentionally; update the consuming code and asset catalog together.

## Art Workflow
- Current art is generated locally by `Tools/GenerateArt.swift` and checked into `Assets.xcassets`.
- To regenerate:
  ```bash
  swift Tools/GenerateArt.swift
  ```
- After adding an image asset:
  - Add/update its `.imageset/Contents.json`.
  - Reference it by catalog name from SwiftUI `Image("Name")` or SpriteKit `SKSpriteNode(imageNamed: "Name")`.
  - Validate asset JSON before building.
- Keep new visuals original and broadly inspired by the reference style, not copied.

## Validation
Use these checks after meaningful changes:

```bash
ruby -rjson -e 'ARGV.each { |file| JSON.parse(File.read(file)); puts "#{file}: OK" }' ZCellSurvivor/Assets.xcassets/**/*.json
plutil -lint ZCellSurvivor/Info.plist ZCellSurvivor.xcodeproj/project.pbxproj
env CLANG_MODULE_CACHE_PATH=.build/ModuleCache swiftc -typecheck ZCellSurvivor/App/*.swift ZCellSurvivor/Views/*.swift ZCellSurvivor/Game/*.swift
```

For Xcode build validation:

```bash
xcodebuild -project ZCellSurvivor.xcodeproj \
  -scheme ZCellSurvivor \
  -configuration Debug \
  -destination generic/platform=iOS \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

If sandboxed execution blocks simulator/CoreSimulator or `.git` writes, request appropriate approval rather than changing the project structure to work around it.

## GitHub Workflow
- Check status before edits and before final response:
  ```bash
  git status --short --branch
  ```
- Keep commits focused and describe user-facing behavior.
- If asked to push, verify `git remote -v` first. The repository should track `origin/main`.
- Do not add ignored personal screenshots or local build artifacts.

## Useful Next Tasks
- Improve responsive layout polish on smaller iPhones.
- Add more original generated sprites and card art.
- Balance enemy wave pacing, upgrade rarity weights, and boss difficulty.
- Add lightweight tests for data model persistence and upgrade application.
- Add a license before making the repository public if reuse terms matter.
