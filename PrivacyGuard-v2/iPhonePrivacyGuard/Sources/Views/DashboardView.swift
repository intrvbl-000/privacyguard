import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var engine: ScanEngine

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    limitsBanner
                    findingsSection
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Privacy Guard")
            .toolbar {
                Button { engine.scan() } label: { Image(systemName: "arrow.clockwise") }
                    .accessibilityLabel("Relancer l'analyse")
            }
            .navigationDestination(for: Finding.self) { FindingDetailView(finding: $0) }
            .sheet(isPresented: Binding(
                get: { !engine.pendingAlerts.isEmpty },
                set: { if !$0 { engine.pendingAlerts = [] } })) {
                AlertSheet(findings: engine.pendingAlerts) { engine.pendingAlerts = [] }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 20) {
            ScoreRing(score: engine.score)
            VStack(alignment: .leading, spacing: 6) {
                Text(engine.statusTitle).font(.title3.bold())
                Text("\(engine.findings.count) point(s) relevé(s)")
                    .foregroundStyle(.secondary)
                if let d = engine.lastScan {
                    Text("Analyse : \(d.formatted(date: .omitted, time: .shortened))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .card()
    }

    private var limitsBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill").foregroundStyle(.blue)
            Text("iOS interdit à une app de lire les profils, Temps d'écran ou les autorisations des autres apps. Un score élevé ne prouve donc pas l'absence de contrôle : complétez l'onglet « Vérifier ».")
                .font(.footnote)
        }
        .card()
    }

    @ViewBuilder private var findingsSection: some View {
        if engine.findings.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill").font(.largeTitle).foregroundStyle(.green)
                Text("Aucun signal détecté automatiquement.").font(.headline)
                Text("Faites les vérifications manuelles pour un tableau complet.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity).card()
        } else {
            ForEach(engine.findings) { f in
                NavigationLink(value: f) {
                    HStack(spacing: 12) {
                        Image(systemName: f.level.icon)
                            .font(.title2).foregroundStyle(f.level.color)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(f.title).font(.headline).multilineTextAlignment(.leading)
                            Text(f.summary).font(.footnote).foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                            RiskBadge(level: f.level)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                    }
                    .card()
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct FindingDetailView: View {
    let finding: Finding

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack { RiskBadge(level: finding.level); Spacer()
                    Text(finding.origin.label).font(.caption).foregroundStyle(.secondary) }
                section("Ce que cela signifie", finding.summary, "text.bubble")
                section("Conséquences possibles", finding.consequences, "eye")
                section("Que faire", finding.advice, "lightbulb")
                section("Où vérifier", finding.whereToCheck, "gearshape")
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Ouvrir les Réglages", systemImage: "arrow.up.forward.app")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Text("Privacy Guard ne modifie ni ne supprime jamais aucune configuration. Toute décision se prend manuellement dans les Réglages iOS.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(finding.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, _ text: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon).font(.subheadline.bold()).foregroundStyle(Theme.accent)
            Text(text)
        }
        .card()
    }
}

/// Explique les conséquences AVANT que l'utilisateur ne prenne une décision.
struct AlertSheet: View {
    let findings: [Finding]
    let dismiss: () -> Void

    var body: some View {
        NavigationStack {
            List(findings) { f in
                VStack(alignment: .leading, spacing: 8) {
                    RiskBadge(level: f.level)
                    Text(f.title).font(.headline)
                    Text("Conséquences : \(f.consequences)").font(.footnote)
                    Text("Conseil : \(f.advice)").font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Nouveau changement")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("J'ai compris", action: dismiss)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
