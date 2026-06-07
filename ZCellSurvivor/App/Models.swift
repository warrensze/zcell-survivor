import Foundation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable, Codable, Sendable {
    case shop
    case character
    case battle
    case weapon
    case artifact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shop: "Shop"
        case .character: "Character"
        case .battle: "Battle"
        case .weapon: "Weapon"
        case .artifact: "Artifact"
        }
    }

    var symbol: String {
        switch self {
        case .shop: "storefront.fill"
        case .character: "heart.fill"
        case .battle: "bolt.badge.a.fill"
        case .weapon: "crossed.swords"
        case .artifact: "sparkles"
        }
    }
}

enum Rarity: String, Codable, CaseIterable, Identifiable, Sendable {
    case common
    case rare
    case epic
    case legendary

    var id: String { rawValue }

    var title: String {
        switch self {
        case .common: "Normal"
        case .rare: "Rare"
        case .epic: "Epic"
        case .legendary: "Legendary"
        }
    }

    var color: Color {
        switch self {
        case .common: Color(red: 0.18, green: 0.77, blue: 0.55)
        case .rare: Color(red: 0.16, green: 0.62, blue: 0.94)
        case .epic: Color(red: 0.61, green: 0.34, blue: 0.95)
        case .legendary: Color(red: 1.0, green: 0.56, blue: 0.18)
        }
    }
}

struct CurrencyWallet: Codable, Sendable {
    var stamina = 30
    var coins = 902_001
    var gems = 65_323
    var tickets = 32
}

struct PlayerProfile: Codable, Sendable {
    var level = 246
    var chapter = 1
    var chapterName = "Sneeze Sector"
    var power = 6_970
    var attack = 458
    var criticalChance = 17.4
    var haste = 32.0
}

struct WeaponItem: Identifiable, Codable, Sendable {
    let id: String
    var name: String
    var rarity: Rarity
    var level: Int
    var symbol: String
    var equipped: Bool
}

struct ArtifactItem: Identifiable, Codable, Sendable {
    let id: String
    var name: String
    var rarity: Rarity
    var stars: Int
    var symbol: String
    var unlocked: Bool
}

struct UpgradeCard: Identifiable, Codable, Equatable, Sendable {
    enum Effect: String, Codable, Sendable {
        case damage
        case fireRate
        case projectileCount
        case pierce
        case speed
        case orbit
    }

    let id: UUID
    var title: String
    var detail: String
    var rarity: Rarity
    var symbol: String
    var effect: Effect
    var amount: Double

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        rarity: Rarity,
        symbol: String,
        effect: Effect,
        amount: Double
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.rarity = rarity
        self.symbol = symbol
        self.effect = effect
        self.amount = amount
    }
}

struct RunLoadout: Sendable {
    var playerLevel: Int
    var attack: Double
    var fireRate: Double
    var moveSpeed: Double
    var projectileCount: Int
    var pierce: Int
    var chapterName: String
}

struct RunResult: Sendable {
    var victory: Bool
    var coinsEarned: Int
    var gemsEarned: Int
    var enemiesDefeated: Int
    var stageName: String
}

private struct PersistedGameState: Codable, Sendable {
    var wallet: CurrencyWallet
    var profile: PlayerProfile
    var weapons: [WeaponItem]
    var artifacts: [ArtifactItem]
}

@MainActor
final class GameState: ObservableObject {
    @Published var selectedTab: AppTab = .battle
    @Published var wallet: CurrencyWallet
    @Published var profile: PlayerProfile
    @Published var weapons: [WeaponItem]
    @Published var artifacts: [ArtifactItem]
    @Published var isRunActive = false
    @Published var lastRunResult: RunResult?

    private let storageKey = "zcell-survivor-state-v1"

    init() {
        if let saved = Self.loadSnapshot(key: storageKey) {
            wallet = saved.wallet
            profile = saved.profile
            weapons = saved.weapons
            artifacts = saved.artifacts
        } else {
            wallet = CurrencyWallet()
            profile = PlayerProfile()
            weapons = Self.defaultWeapons
            artifacts = Self.defaultArtifacts
        }
    }

    var equippedWeapon: WeaponItem {
        weapons.first(where: \.equipped) ?? weapons[0]
    }

    var chapterProgress: Double {
        min(1.0, Double(profile.chapter - 1) / 5.0)
    }

    func makeLoadout() -> RunLoadout {
        let weaponBonus = Double(equippedWeapon.level) * 8
        let artifactBonus = Double(artifacts.filter(\.unlocked).map(\.stars).reduce(0, +)) * 6
        return RunLoadout(
            playerLevel: profile.level,
            attack: Double(profile.attack) + weaponBonus + artifactBonus,
            fireRate: 0.55,
            moveSpeed: 240,
            projectileCount: 1,
            pierce: 0,
            chapterName: profile.chapterName
        )
    }

    func beginRun() {
        guard wallet.stamina >= 5 else { return }
        wallet.stamina -= 5
        save()
        isRunActive = true
    }

    func sweepChapter() {
        guard wallet.stamina >= 5 else { return }
        wallet.stamina -= 5
        wallet.coins += 250
        save()
    }

    func completeRun(_ result: RunResult) {
        wallet.coins += result.coinsEarned
        wallet.gems += result.gemsEarned
        if result.victory {
            profile.chapter += 1
            profile.power += 310
            profile.chapterName = Self.chapterName(for: profile.chapter)
        }
        lastRunResult = result
        isRunActive = false
        save()
    }

    func upgradeCharacterStat(_ keyPath: WritableKeyPath<PlayerProfile, Int>, cost: Int) {
        guard wallet.coins >= cost else { return }
        wallet.coins -= cost
        profile[keyPath: keyPath] += 1
        profile.power += 15
        save()
    }

    func upgradeWeapon(_ weapon: WeaponItem) {
        guard let index = weapons.firstIndex(where: { $0.id == weapon.id }) else { return }
        let cost = 300 + weapons[index].level * 90
        guard wallet.coins >= cost else { return }
        wallet.coins -= cost
        weapons[index].level += 1
        profile.power += 20
        save()
    }

    func equipWeapon(_ weapon: WeaponItem) {
        for index in weapons.indices {
            weapons[index].equipped = weapons[index].id == weapon.id
        }
        save()
    }

    func buyOfflineChest() {
        guard wallet.gems >= 80 else { return }
        wallet.gems -= 80
        wallet.coins += 1_200
        if let lockedIndex = artifacts.firstIndex(where: { !$0.unlocked }) {
            artifacts[lockedIndex].unlocked = true
        }
        save()
    }

    private func save() {
        let snapshot = PersistedGameState(
            wallet: wallet,
            profile: profile,
            weapons: weapons,
            artifacts: artifacts
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func loadSnapshot(key: String) -> PersistedGameState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PersistedGameState.self, from: data)
    }

    private static func chapterName(for chapter: Int) -> String {
        let names = ["Sneeze Sector", "Pollen Run", "Syrup Canal", "Fever Reef", "Antibody Gate", "Plasma Garden"]
        return names[(chapter - 1) % names.count]
    }

    private static let defaultWeapons: [WeaponItem] = [
        WeaponItem(id: "capsule", name: "Capsule", rarity: .common, level: 15, symbol: "capsule.fill", equipped: true),
        WeaponItem(id: "skyfall", name: "Skyfall Spark", rarity: .legendary, level: 9, symbol: "sparkles", equipped: false),
        WeaponItem(id: "nebula", name: "Nebula Needle", rarity: .epic, level: 8, symbol: "wand.and.stars", equipped: false),
        WeaponItem(id: "sprayer", name: "Mist Sprayer", rarity: .rare, level: 12, symbol: "drop.fill", equipped: false),
        WeaponItem(id: "orbiter", name: "Orbit Ring", rarity: .rare, level: 7, symbol: "circle.hexagongrid.fill", equipped: false),
        WeaponItem(id: "tide", name: "Tide Lance", rarity: .epic, level: 5, symbol: "moonphase.waning.crescent", equipped: false)
    ]

    private static let defaultArtifacts: [ArtifactItem] = [
        ArtifactItem(id: "hammer", name: "Tiny Hammer", rarity: .common, stars: 2, symbol: "hammer.fill", unlocked: true),
        ArtifactItem(id: "tube", name: "Type 37", rarity: .common, stars: 1, symbol: "testtube.2", unlocked: true),
        ArtifactItem(id: "mask", name: "Face Mask", rarity: .common, stars: 3, symbol: "facemask.fill", unlocked: true),
        ArtifactItem(id: "plunger", name: "Plunger", rarity: .common, stars: 1, symbol: "paintbrush.pointed.fill", unlocked: true),
        ArtifactItem(id: "collector", name: "Collector Jar", rarity: .rare, stars: 1, symbol: "shippingbox.fill", unlocked: false),
        ArtifactItem(id: "scanner", name: "Pulse Scanner", rarity: .rare, stars: 2, symbol: "waveform.path.ecg", unlocked: false),
        ArtifactItem(id: "shield", name: "Blue Shield", rarity: .epic, stars: 1, symbol: "shield.lefthalf.filled", unlocked: false),
        ArtifactItem(id: "star", name: "Serum Star", rarity: .legendary, stars: 1, symbol: "star.circle.fill", unlocked: false)
    ]
}
