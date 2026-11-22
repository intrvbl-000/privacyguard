import SwiftUI

struct AccountsView: View {
    @AppStorage("pg.accountDone") private var doneRaw = ""

    private var done: Set<String> { Set(doneRaw.split(separator: ",").map(String.init)) }

    private func toggle(_ id: String) {
        var s = done
        if s.contains(id) { s.remove(id) } else { s.insert(id) }
        doneRaw = s.sorted().joined(separator: ",")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ProgressView(value: Double(done.count), total: Double(Catalog.accountTasks.count))
                        .tint(.green)
                    Text("\(done.count)/\(Catalog.accountTasks.count) actions faites")
                        .font(.caption).foregroundStyle(.secondary)

                    ForEach(Catalog.accountTasks) { t in
                        Button { toggle(t.id) } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: done.contains(t.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundStyle(done.contains(t.id) ? .green : .secondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(t.title).font(.headline).multilineTextAlignment(.leading)
                                    Text(t.detail).font(.footnote).foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .card()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Comptes")
        }
    }
}
