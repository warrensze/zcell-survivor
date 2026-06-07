import SpriteKit
import SwiftUI

struct RunHUD: Sendable {
    var stageTitle: String
    var health: Double
    var enemiesDefeated: Int
    var elapsed: Int
}

@MainActor
final class RunCoordinator: ObservableObject {
    @Published var offeredUpgrades: [UpgradeCard] = []
    @Published var result: RunResult?
    @Published var hud = RunHUD(stageTitle: "Stage 1", health: 1, enemiesDefeated: 0, elapsed: 0)

    weak var scene: GameScene?

    func showUpgradeChoices(_ choices: [UpgradeCard]) {
        offeredUpgrades = choices
    }

    func finish(_ result: RunResult) {
        self.result = result
    }

    func updateHUD(_ hud: RunHUD) {
        self.hud = hud
    }
}

struct GameContainerView: View {
    @EnvironmentObject private var state: GameState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var coordinator = RunCoordinator()
    @State private var scene: GameScene?

    var loadout: RunLoadout

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if let scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                } else {
                    Color.cyan
                        .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    GameTopOverlay(hud: coordinator.hud) {
                        scene?.finishRun(victory: false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    Spacer()
                }

                if !coordinator.offeredUpgrades.isEmpty {
                    UpgradeChoiceOverlay(cards: coordinator.offeredUpgrades) { card in
                        scene?.applyUpgrade(card)
                        coordinator.offeredUpgrades = []
                    }
                }
            }
            .onAppear {
                if scene == nil {
                    let newScene = GameScene(size: proxy.size)
                    newScene.scaleMode = .resizeFill
                    newScene.coordinator = coordinator
                    newScene.configure(loadout: loadout)
                    coordinator.scene = newScene
                    scene = newScene
                }
            }
            .onReceive(coordinator.$result.compactMap { $0 }) { result in
                state.completeRun(result)
                dismiss()
            }
        }
    }
}

private struct GameTopOverlay: View {
    var hud: RunHUD
    var close: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: close) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.purple.opacity(0.75), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(.plain)

            VStack(spacing: 4) {
                Text(hud.stageTitle)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("Easy")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 12)
                    .frame(height: 22)
                    .background(.black.opacity(0.35), in: Capsule())
                ProgressView(value: hud.health)
                    .tint(.red)
                    .frame(width: 150)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(hud.enemiesDefeated)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(hud.elapsed)s")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct UpgradeChoiceOverlay: View {
    var cards: [UpgradeCard]
    var select: (UpgradeCard) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                RibbonTitle(title: "Enhance Attributes", tint: .yellow)
                    .padding(.horizontal, 28)

                HStack(spacing: 6) {
                    ForEach(Rarity.allCases) { rarity in
                        Text(rarity.title)
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 9)
                            .frame(height: 24)
                            .background(rarity.color.gradient, in: Capsule())
                    }
                }

                HStack(spacing: 10) {
                    ForEach(cards) { card in
                        Button {
                            select(card)
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.18))
                                        .frame(width: 60)
                                    Image(systemName: card.symbol)
                                        .font(.system(size: 30, weight: .black))
                                        .foregroundStyle(.white)
                                }

                                Text(card.title)
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.72)

                                Text(card.detail)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(4)
                                    .minimumScaleFactor(0.7)

                                Spacer(minLength: 0)
                                RarityBadge(rarity: card.rarity)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .background(card.rarity.color.gradient, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.55), lineWidth: 1.2))
                            .shadow(color: card.rarity.color.opacity(0.4), radius: 10, y: 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)

                Button {
                    if let first = cards.randomElement() {
                        select(first)
                    }
                } label: {
                    Label("Free Refresh", systemImage: "arrow.clockwise")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 190, height: 48)
                        .background(.cyan.gradient, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 24)
        }
    }
}
