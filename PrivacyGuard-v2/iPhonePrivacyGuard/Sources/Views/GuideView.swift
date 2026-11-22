import SwiftUI

struct GuideView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Voir qui utilise quoi", systemImage: "chart.bar.doc.horizontal")
                            .font(.headline)
                        Text("Pour contrôler les autorisations de toutes vos apps, utilisez Réglages > Confidentialité et sécurité (une rubrique par type de donnée) et le Rapport de confidentialité des apps. Une app tierce ne peut pas lire ces listes à votre place.")
                            .font(.footnote)
                    }.card()

                    ForEach(Catalog.permissions) { p in
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("**Accès :** \(p.access)")
                                Text("**À savoir :** \(p.risk)")
                            }
                            .font(.footnote)
                            .padding(.top, 6)
                        } label: {
                            Label(p.name, systemImage: p.icon).font(.headline)
                        }
                        .card()
                    }

                    ProfileExplainer()
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Autorisations")
        }
    }
}

/// Explication à lire AVANT d'accepter un profil (iOS demande lui-même la validation ; l'app ne peut pas l'intercepter).
struct ProfileExplainer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Avant d'installer un profil", systemImage: "doc.badge.gearshape").font(.headline)
            Text("Un profil de configuration peut, selon son contenu : imposer des restrictions, configurer un VPN, un Wi-Fi ou un compte mail, et installer des certificats. Avec un certificat racine approuvé, du trafic chiffré peut devenir lisible par l'émetteur.")
            Text("Avant d'accepter : sachez qui vous l'envoie, lisez la liste « Détails » affichée par iOS, et sachez que sa suppression pourra être limitée ou entraîner la perte de services (Wi-Fi, mail pro).")
            Text("Privacy Guard ne peut pas bloquer ni valider un profil à votre place : cette décision reste la vôtre dans les Réglages.")
                .foregroundStyle(.secondary)
        }
        .font(.footnote)
        .card()
    }
}
