import SwiftUI

struct BattleHubView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                RibbonTitle(title: "Chapter \(state.profile.chapter)  \(state.profile.chapterName)")

                Panel(tint: .orange) {
                    ZStack {
                        Image("BattleHubScene")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(spacing: 10) {
                            Text("Normal")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 12)
                                .frame(height: 24)
                                .background(.white.opacity(0.75), in: Capsule())

                            Text("Recommended \(state.profile.power)")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .frame(height: 24)
                                .background(.red.opacity(0.75), in: Capsule())

                            Spacer()
                        }
                        .padding(18)
                    }
                }

                Panel(tint: .green) {
                    HStack {
                        Text("Highest Survival Progress")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(state.chapterProgress * 100))%")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(.yellow)
                    }

                    ProgressView(value: state.chapterProgress)
                        .tint(.yellow)

                    HStack(spacing: 10) {
                        RewardChest(label: "25%", unlocked: state.chapterProgress >= 0.25)
                        RewardChest(label: "50%", unlocked: state.chapterProgress >= 0.50)
                        RewardChest(label: "100%", unlocked: state.chapterProgress >= 1.0)
                    }

                    HStack(spacing: 12) {
                        SoftButton(title: "Sweep", symbol: "wind", tint: .lime, subtitle: "x5 stamina") {
                            state.sweepChapter()
                        }

                        SoftButton(title: "Start Battle", symbol: "play.fill", tint: .orange, subtitle: "x5 stamina") {
                            state.beginRun()
                        }
                    }
                }

                if let result = state.lastRunResult {
                    Panel(tint: result.victory ? .green : .red) {
                        Text(result.victory ? "Last run cleared" : "Last run survived")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("+\(result.coinsEarned) coins  +\(result.gemsEarned) gems  \(result.enemiesDefeated) enemies")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                }
            }
            .padding(.bottom, 8)
        }
    }
}

private struct RewardChest: View {
    var label: String
    var unlocked: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: unlocked ? "shippingbox.fill" : "lock.fill")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(unlocked ? .yellow : .white.opacity(0.65))
            Text(label)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ShopView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                RibbonTitle(title: "Chapter Chest", tint: .yellow)

                Panel(tint: .green) {
                    HStack(spacing: 14) {
                        Image("ChestIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 86, height: 86)
                            .background(.green.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Guardian Cache")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Offline bundle with coins and one collection unlock.")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))
                            Button {
                                state.buyOfflineChest()
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Open")
                                    Image("GemIcon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                    Text("80")
                                }
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .frame(height: 36)
                                .background(.purple.gradient, in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }

                RibbonTitle(title: "Special Offer", tint: .orange)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ShopCard(title: "Diamonds", imageName: "GemIcon", price: "5 tickets", tint: .purple)
                    ShopCard(title: "Green Chest", imageName: "ChestIcon", price: "80 gems", tint: .green)
                    ShopCard(title: "Bandage Pack", symbol: "bandage.fill", price: "42 gems", tint: .orange)
                    ShopCard(title: "Pill Fragments", imageName: "CapsuleShot", price: "60 gems", tint: .blue)
                }
            }
        }
    }
}

private struct ShopCard: View {
    var title: String
    var symbol: String?
    var imageName: String?
    var price: String
    var tint: Color

    init(title: String, symbol: String, price: String, tint: Color) {
        self.title = title
        self.symbol = symbol
        self.imageName = nil
        self.price = price
        self.tint = tint
    }

    init(title: String, imageName: String, price: String, tint: Color) {
        self.title = title
        self.symbol = nil
        self.imageName = imageName
        self.price = price
        self.tint = tint
    }

    var body: some View {
        VStack(spacing: 8) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
            } else if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(price)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 132)
        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.45), lineWidth: 1))
    }
}

struct CharacterView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                Panel(tint: .purple) {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            Text("Heartlet")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            RarityBadge(rarity: .epic)
                            Spacer()
                        }

                        Image("HeroCell")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 132, height: 132)
                            .shadow(color: .red.opacity(0.35), radius: 10, y: 6)

                        ProgressView(value: Double(state.profile.level % 10), total: 10)
                            .tint(.yellow)
                        HStack {
                            Text("Level \(state.profile.level)")
                            Spacer()
                            Text("Next \(state.profile.level + 10)")
                        }
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    }
                }

                HStack(spacing: 10) {
                    StatTile(symbol: "bolt.fill", title: "Attack", value: "\(state.profile.attack)", tint: .orange)
                    StatTile(symbol: "flame.fill", title: "Crit", value: String(format: "%.1f%%", state.profile.criticalChance), tint: .red)
                    StatTile(symbol: "hare.fill", title: "Haste", value: String(format: "%.1f%%", state.profile.haste), tint: .cyan)
                }

                Panel(tint: .orange) {
                    Text("Training")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    SoftButton(title: "Level Up", symbol: "arrow.up.circle.fill", tint: .orange, subtitle: "15.5K coins") {
                        state.upgradeCharacterStat(\.level, cost: 15_525)
                    }
                    SoftButton(title: "Boost Attack", symbol: "crosshair", tint: .red, subtitle: "6.5K coins") {
                        state.upgradeCharacterStat(\.attack, cost: 6_525)
                    }
                }
            }
        }
    }
}

struct WeaponView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                RibbonTitle(title: "Equipped Weapon", tint: .orange)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(state.weapons.filter(\.equipped)) { weapon in
                        WeaponCard(weapon: weapon, isEquipped: true)
                    }
                }

                RibbonTitle(title: "Owned", tint: .blue)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(state.weapons.filter { !$0.equipped }) { weapon in
                        WeaponCard(weapon: weapon, isEquipped: false)
                    }
                }
            }
        }
    }
}

private struct WeaponCard: View {
    @EnvironmentObject private var state: GameState
    var weapon: WeaponItem
    var isEquipped: Bool

    var body: some View {
        VStack(spacing: 7) {
            HStack {
                RarityBadge(rarity: weapon.rarity)
                Spacer()
                Text("Lv\(weapon.level)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            Image(weapon.id == "orbiter" ? "WeaponOrb" : weapon.id == "capsule" ? "CapsuleShot" : "CapsuleShot")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
            Text(weapon.name)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            HStack(spacing: 6) {
                Button(isEquipped ? "Equipped" : "Equip") {
                    state.equipWeapon(weapon)
                }
                .disabled(isEquipped)

                Button("Up") {
                    state.upgradeWeapon(weapon)
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .controlSize(.mini)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .frame(height: 152)
        .background(weapon.rarity.color.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(weapon.rarity.color.opacity(0.7), lineWidth: 1))
    }
}

struct ArtifactView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(Rarity.allCases) { rarity in
                    let items = state.artifacts.filter { $0.rarity == rarity }
                    if !items.isEmpty {
                        RibbonTitle(title: rarity.title, tint: rarity.color)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            ForEach(items) { item in
                                ArtifactCard(item: item)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ArtifactCard: View {
    var item: ArtifactItem

    var body: some View {
        VStack(spacing: 8) {
            if item.unlocked {
                Image(item.id == "hammer" ? "ArtifactHammer" : "WeaponOrb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Text(item.unlocked ? item.name : "Available")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < item.stars ? "star.fill" : "star")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.yellow)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .background(item.rarity.color.opacity(item.unlocked ? 0.28 : 0.12), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(item.rarity.color.opacity(0.55), lineWidth: 1))
    }
}

private extension Color {
    static let lime = Color(red: 0.72, green: 0.86, blue: 0.22)
}
