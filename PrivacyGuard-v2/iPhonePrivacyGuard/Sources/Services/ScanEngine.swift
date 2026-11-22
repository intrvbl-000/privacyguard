import Foundation
import SwiftUI

@MainActor
final class ScanEngine: ObservableObject {
    static let shared = ScanEngine()

    @Published private(set) var findings: [Finding] = []
    @Published private(set) var score: Int = 100
    @Published private(set) var lastScan: Date?
    @Published private(set) var answers: [String: Answer] = [:]
    /// Changements apparus depuis le dernier scan, à expliquer à l'utilisateur.
    @Published var pendingAlerts: [Finding] = []

    private let defaults = UserDefaults.standard
    private let answersKey = "pg.answers"
    private let snapshotKey = "pg.snapshot"
    private let knownApps = DeviceSignals.loadKnownApps()

    init() {
        if let raw = defaults.dictionary(forKey: answersKey) as? [String: String] {
            answers = raw.compactMapValues(Answer.init(rawValue:))
        }
    }

    func setAnswer(_ answer: Answer, for id: String) {
        answers[id] = answer
        defaults.set(answers.mapValues(\.rawValue), forKey: answersKey)
        scan()
    }

    func scan() {
        var list: [Finding] = []

        if DeviceSignals.vpnActive() { list.append(Catalog.vpn) }
        if DeviceSignals.proxyConfigured() { list.append(Catalog.proxy) }
        if DeviceSignals.managedAppConfigPresent() { list.append(Catalog.managedConfig) }
        for app in DeviceSignals.installedKnownApps(knownApps) { list.append(Catalog.knownApp(app)) }

        for item in Catalog.checklist where answers[item.id] == .yes {
            list.append(item.finding)
        }

        list.sort { $0.level > $1.level }
        findings = list
        score = max(0, 100 - list.reduce(0) { $0 + $1.level.weight })
        lastScan = Date()

        // Détection des NOUVEAUX signaux depuis le scan précédent (signaux automatiques uniquement).
        let current = Set(list.filter { $0.origin == .automatic }.map(\.id))
        if let previous = defaults.stringArray(forKey: snapshotKey) {
            let added = current.subtracting(previous)
            let newFindings = list.filter { added.contains($0.id) }
            if !newFindings.isEmpty {
                pendingAlerts = newFindings
                AlertService.notifyNew(newFindings)
            }
        }
        defaults.set(Array(current), forKey: snapshotKey)
    }

    var statusTitle: String {
        switch score {
        case 80...: return "Peu de signaux détectés"
        case 50..<80: return "Quelques points à examiner"
        default: return "Plusieurs points importants"
        }
    }
}
