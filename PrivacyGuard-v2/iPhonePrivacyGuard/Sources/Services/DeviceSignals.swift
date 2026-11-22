import Foundation
import CFNetwork
import UIKit

/// Seuls signaux que iOS permet réellement de lire à une app normale (App Store, sans jailbreak).
/// Ce sont des INDICES, pas des preuves.
enum DeviceSignals {

    /// Heuristique : une interface tunnel (utun/ppp/ipsec…) est présente dans les réglages réseau.
    /// Peut être un faux positif (iCloud Private Relay, services système).
    static func vpnActive() -> Bool {
        guard let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = dict["__SCOPED__"] as? [String: Any] else { return false }
        let prefixes = ["tap", "tun", "ppp", "ipsec", "utun"]
        return scoped.keys.contains { key in
            prefixes.contains { key.lowercased().hasPrefix($0) }
        }
    }

    /// Un proxy HTTP/HTTPS ou un fichier PAC est configuré pour le réseau courant.
    static func proxyConfigured() -> Bool {
        guard let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else { return false }
        func on(_ key: String) -> Bool { (dict[key] as? Int ?? 0) == 1 }
        return on("HTTPEnable") || on("HTTPSEnable") || on("ProxyAutoConfigEnable")
    }

    /// Présent uniquement si un MDM a poussé une configuration d'app À CETTE APP.
    /// Son absence ne prouve PAS que l'appareil n'est pas géré.
    static func managedAppConfigPresent() -> Bool {
        UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed") != nil
    }

    /// Détection par schéma d'URL. Limites : seules les apps qui déclarent ce schéma
    /// ET figurent dans LSApplicationQueriesSchemes sont visibles. iOS ne fournit pas
    /// de liste des apps installées.
    @MainActor
    static func installedKnownApps(_ apps: [KnownApp]) -> [KnownApp] {
        apps.filter { app in
            guard let url = URL(string: "\(app.scheme)://") else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }

    static func loadKnownApps() -> [KnownApp] {
        guard let url = Bundle.main.url(forResource: "known_apps", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let apps = try? JSONDecoder().decode([KnownApp].self, from: data) else { return [] }
        return apps
    }
}
