import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        ZStack {
            AppBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TopStatusBar()
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                TabContentView()
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                BottomNavigationBar()
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                    .padding(.top, 6)
            }
        }
        .runPresentation(isPresented: $state.isRunActive) {
            GameContainerView(loadout: state.makeLoadout())
                .environmentObject(state)
        }
    }
}

private struct TabContentView: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        Group {
            switch state.selectedTab {
            case .shop:
                ShopView()
            case .character:
                CharacterView()
            case .battle:
                BattleHubView()
            case .weapon:
                WeaponView()
            case .artifact:
                ArtifactView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension View {
    @ViewBuilder
    func runPresentation<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(isPresented: isPresented, content: content)
        #else
        sheet(isPresented: isPresented, content: content)
        #endif
    }
}
