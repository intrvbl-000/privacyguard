import SwiftUI

/// Vérification guidée : iOS ne laisse pas une app lire ces informations,
/// c'est donc l'utilisateur qui regarde dans les Réglages et répond.
struct AuditView: View {
    @EnvironmentObject var engine: ScanEngine

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Ces points sont visibles uniquement dans les Réglages iOS. Regardez, puis répondez : Privacy Guard vous explique ce que cela implique.")
                        .font(.footnote).foregroundStyle(.secondary)
                    ForEach(Catalog.checklist) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.question).font(.headline)
                            Label(item.path, systemImage: "location.north.line")
                                .font(.caption).foregroundStyle(.secondary)
                            Picker("Réponse", selection: Binding(
                                get: { engine.answers[item.id] },
                                set: { if let a = $0 { engine.setAnswer(a, for: item.id) } })) {
                                ForEach(Answer.allCases, id: \.self) { Text($0.label).tag(Optional($0)) }
                            }
                            .pickerStyle(.segmented)
                        }
                        .card()
                    }
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Vérifier")
        }
    }
}
