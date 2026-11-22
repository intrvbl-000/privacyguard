import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearance = Appearance.system.rawValue
    @AppStorage("pg.weekly") private var weekly = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Apparence") {
                    Picker("Thème", selection: $appearance) {
                        ForEach(Appearance.allCases) { Text($0.label).tag($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Alertes") {
                    Toggle("Rappel hebdomadaire de vérification", isOn: $weekly)
                        .onChange(of: weekly) { AlertService.setWeeklyReminder(enabled: $0) }
                }
                Section("Transparence") {
                    NavigationLink("Ce que l'app peut et ne peut pas faire") { LimitsView() }
                    Text("Aucune donnée ne quitte votre iPhone. L'app n'a aucun accès réseau, aucun compte, aucun outil de suivi.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Réglages")
        }
    }
}

struct LimitsView: View {
    private let can = [
        "Repérer des indices : tunnel VPN actif, proxy configuré, configuration d'app gérée reçue par l'app.",
        "Repérer certaines apps connues (par schéma d'URL, liste limitée et non exhaustive).",
        "Vous guider pas à pas dans les Réglages et expliquer chaque point simplement.",
        "Vous alerter si un indice automatique apparaît entre deux analyses.",
        "Vous rappeler régulièrement de revérifier.",
    ]
    private let cannot = [
        "Lister les apps installées : iOS ne fournit aucune API pour cela.",
        "Lire les profils de configuration ou l'état MDM / supervision : réservé au système.",
        "Savoir si Temps d'écran ou Partage familial est actif, ni son code : réservé au système.",
        "Lire les autorisations accordées aux autres apps : seul Réglages les montre.",
        "Être prévenu quand un profil est installé ou une autorisation accordée à une autre app.",
        "Supprimer ou modifier un profil, une restriction ou une app de contrôle : volontairement impossible, et Privacy Guard ne tente jamais de contourner Apple.",
        "Garantir qu'aucun contrôle n'existe : un score élevé n'est jamais une preuve.",
    ]

    var body: some View {
        List {
            Section("Possible") {
                ForEach(can, id: \.self) { Label($0, systemImage: "checkmark.circle.fill").foregroundStyle(.primary) }
            }
            Section("Impossible sur iOS") {
                ForEach(cannot, id: \.self) { Label($0, systemImage: "xmark.circle.fill").foregroundStyle(.primary) }
            }
        }
        .navigationTitle("Limites d'iOS")
    }
}
