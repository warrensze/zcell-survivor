# Cell Survivor-Inspired iOS Game Plan

## Summary
Build a native Swift iOS game in Xcode using a SwiftUI app shell and a SpriteKit gameplay scene. The first version is a playable vertical slice: Battle hub, one stage, wave combat, boss encounter, upgrade-card picker, and offline progression.

The visual direction is inspired by the provided Cell Survivor screenshots, but the implementation should use original names, icons, colors, layouts, and assets.

## Architecture
- Native iOS app written in Swift.
- SwiftUI handles menus, overlays, navigation, persistent UI, and progression screens.
- SpriteKit handles real-time gameplay, movement, projectiles, enemies, collisions, damage numbers, and boss combat.
- Portrait-first iPhone layout with safe-area support for notched devices.
- Local-only persistence for v1 using JSON or UserDefaults.

## Screens
- Battle hub: chapter card, start battle button, sweep button placeholder, chest/progress row, currencies, side shortcuts, bottom tab bar.
- Shop: offline special offers, chest cards, item cards, and fake currency purchases only.
- Character: central hero display, level/progress track, stat upgrade cards, cosmetic preview/wardrobe placeholders.
- Weapon: equipped weapon grid, owned weapon grid, rarity colors, upgrade/equip actions.
- Artifact: collection grid, rarity sections, locked/available states, star ratings, collection/set toggle.
- Gameplay: blue microscopic arena, player hero, enemy waves, top stage metadata, pause button, damage numbers, boss encounter.
- Upgrade picker: three weighted upgrade cards, rarity colors, refresh option, and obtain-all placeholder using offline currency.

## Gameplay Loop
- Player taps Start Battle from the Battle hub.
- Stage loads with a selected character, weapon, artifacts, and base stats.
- Player moves in a SpriteKit arena while weapons auto-fire.
- Enemies spawn in waves and move toward the player.
- Projectiles damage enemies; defeated enemies grant experience and/or run progress.
- At wave milestones, pause action and show three upgrade-card choices.
- A boss spawns near the end of the stage.
- Victory grants offline rewards and chapter progress; defeat grants partial rewards.

## Data Interfaces
- App state owns selected tab, currencies, stamina, player profile, chapter progress, and inventory.
- `RunLoadout` should pass character stats, equipped weapon, artifact bonuses, and selected stage into SpriteKit.
- `RunResult` should return victory/defeat, earned coins, earned gems, unlocked items, and chapter progress to SwiftUI.
- Upgrade cards should support weighted rarity tiers: common, rare, epic, legendary.
- Upgrade effects should cover projectile count, fire rate, damage, movement speed, piercing, and area effects.

## Monetization
- V1 uses an offline fake economy only.
- No real ads, tracking, StoreKit, or production purchases in the first build.
- Shop and refresh flows should be designed so StoreKit can be added later without rewriting menus.

## Test Plan
- Build and run in Xcode simulator and on a physical iPhone if available.
- Verify portrait layout on common iPhone sizes, including notched devices.
- Confirm bottom tabs open the correct screens and preserve state.
- Confirm Start Battle launches gameplay from the Battle hub.
- Confirm enemies spawn, projectiles fire, collisions apply, damage numbers appear, and health changes.
- Confirm upgrade picker appears at wave milestones and applies selected effects.
- Confirm boss encounter ends the run with victory or defeat.
- Confirm offline progression persists after app relaunch.
- Confirm no network, real payment, ad, or tracking dependency exists in v1.

## Assumptions
- "Native iOS programming language" means Swift.
- Recommended implementation is SwiftUI plus SpriteKit, not Unity or a cross-platform framework.
- V1 scope is a playable slice, not a full clone.
- The app should be inspired by the screenshots while avoiding copied assets, exact UI art, protected names, and production monetization patterns.
- Local setup note: `xcodebuild` currently points at Command Line Tools, so before simulator builds, full Xcode should be installed/opened and selected with `xcode-select`.
