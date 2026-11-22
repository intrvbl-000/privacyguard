import SwiftUI

enum RiskLevel: Int, Comparable, Hashable {
    case info = 0, low, medium, high

    static func < (a: RiskLevel, b: RiskLevel) -> Bool { a.rawValue < b.rawValue }

    var label: String {
        switch self {
        case .info: return "Information"
        case .low: return "Faible"
        case .medium: return "À examiner"
        case .high: return "Important"
        }
    }
    var color: Color {
        switch self {
        case .info: return .blue
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        }
    }
    /// Poids retiré du score de signaux.
    var weight: Int {
        switch self {
        case .info: return 2
        case .low: return 5
        case .medium: return 12
        case .high: return 25
        }
    }
}

enum Origin: Hashable {
    case automatic   // indice observé par l'app (heuristique)
    case declared    // réponse donnée par l'utilisateur après vérification manuelle

    var label: String {
        switch self {
        case .automatic: return "Indice détecté automatiquement"
        case .declared: return "Déclaré par vous"
        }
    }
}

struct Finding: Identifiable, Hashable {
    let id: String            // sert aussi de clé de "signal" pour détecter les changements
    let title: String
    let summary: String
    let consequences: String
    let advice: String
    let whereToCheck: String
    let level: RiskLevel
    let origin: Origin
}

enum Answer: String, CaseIterable {
    case yes, no, unsure
    var label: String {
        switch self {
        case .yes: return "Oui"
        case .no: return "Non"
        case .unsure: return "Pas sûr"
        }
    }
}

struct KnownApp: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let scheme: String
    let category: String
    let verified: Bool
}

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "Système"
        case .light: return "Clair"
        case .dark: return "Sombre"
        }
    }
    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
