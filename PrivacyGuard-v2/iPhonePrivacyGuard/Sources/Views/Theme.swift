import SwiftUI

enum Theme {
    static let accent = Color(red: 0.25, green: 0.45, blue: 0.95)

    static var background: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color.accentColor.opacity(0.08)],
            startPoint: .top, endPoint: .bottom)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}

struct RiskBadge: View {
    let level: RiskLevel
    var body: some View {
        Label(level.label, systemImage: level.icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(level.color.opacity(0.15), in: Capsule())
            .foregroundStyle(level.color)
    }
}

struct ScoreRing: View {
    let score: Int
    private var color: Color { score >= 80 ? .green : (score >= 50 ? .orange : .red) }

    var body: some View {
        ZStack {
            Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 14)
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: score)
            VStack(spacing: 0) {
                Text("\(score)").font(.system(size: 40, weight: .bold, design: .rounded))
                Text("signaux").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score de signaux : \(score) sur 100")
    }
}
