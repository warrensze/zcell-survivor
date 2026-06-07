import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.32, blue: 0.62),
                Color(red: 0.16, green: 0.55, blue: 0.76),
                Color(red: 0.63, green: 0.87, blue: 0.70)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            BubbleField()
                .opacity(0.35)
        }
    }
}

private struct BubbleField: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .stroke(.white.opacity(0.35), lineWidth: 1.5)
                    .frame(width: CGFloat(18 + (index % 5) * 12))
                    .position(
                        x: CGFloat((index * 53) % Int(max(width, 1))),
                        y: CGFloat((index * 97) % Int(max(height, 1)))
                    )
            }
        }
    }
}

struct TopStatusBar: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        HStack(spacing: 7) {
            CurrencyPill(symbol: "bolt.fill", value: state.wallet.stamina, tint: .green)
            CurrencyPill(imageName: "CoinIcon", value: state.wallet.coins, tint: .yellow)
            CurrencyPill(imageName: "GemIcon", value: state.wallet.gems, tint: .purple)
            CurrencyPill(imageName: "TicketIcon", value: state.wallet.tickets, tint: .orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CurrencyPill: View {
    var symbol: String?
    var imageName: String?
    var value: Int
    var tint: Color

    init(symbol: String, value: Int, tint: Color) {
        self.symbol = symbol
        self.imageName = nil
        self.value = value
        self.tint = tint
    }

    init(imageName: String, value: Int, tint: Color) {
        self.symbol = nil
        self.imageName = imageName
        self.value = value
        self.tint = tint
    }

    var body: some View {
        HStack(spacing: 4) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else if let symbol {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                    .font(.system(size: 13, weight: .black))
            }
            Text(compactNumber(value))
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.white.opacity(0.8), tint)
                .font(.system(size: 10, weight: .bold))
        }
        .padding(.horizontal, 7)
        .frame(height: 26)
        .background(.black.opacity(0.32), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
    }
}

struct BottomNavigationBar: View {
    @EnvironmentObject private var state: GameState

    var body: some View {
        HStack(spacing: 7) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    state.selectedTab = tab
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 20, weight: .heavy))
                        Text(tab.title)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(state.selectedTab == tab ? .white : .white.opacity(0.72))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(state.selectedTab == tab ? Color.orange : Color.black.opacity(0.28))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(state.selectedTab == tab ? .white.opacity(0.45) : .white.opacity(0.14), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.black.opacity(0.32), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct Panel<Content: View>: View {
    var tint: Color = .white
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.35), lineWidth: 1.2)
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
    }
}

struct RibbonTitle: View {
    var title: String
    var tint: Color = Color(red: 0.92, green: 0.98, blue: 0.28)

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
            .padding(.horizontal, 22)
            .frame(height: 42)
            .background(tint.gradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.45), lineWidth: 1))
            .frame(maxWidth: .infinity)
    }
}

struct SoftButton: View {
    var title: String
    var symbol: String
    var tint: Color
    var subtitle: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                HStack(spacing: 7) {
                    Image(systemName: symbol)
                    Text(title)
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(tint.gradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.45), lineWidth: 1))
            .shadow(color: tint.opacity(0.35), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct RarityBadge: View {
    var rarity: Rarity

    var body: some View {
        Text(rarity.title)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(rarity.color.gradient, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
    }
}

struct StatTile: View {
    var symbol: String
    var title: String
    var value: String
    var tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.15), lineWidth: 1))
    }
}

func compactNumber(_ value: Int) -> String {
    if value >= 1_000_000 {
        return String(format: "%.1fM", Double(value) / 1_000_000)
    }
    if value >= 10_000 {
        return String(format: "%.1fK", Double(value) / 1_000)
    }
    return "\(value)"
}
