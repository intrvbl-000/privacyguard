import Foundation
import UserNotifications
import BackgroundTasks

/// Alertes 100 % locales. Aucune donnée n'est envoyée sur Internet.
enum AlertService {
    static let taskID = "com.example.privacyguard.refresh"   // à adapter à votre Bundle ID
    private static let weeklyID = "pg.weekly.review"

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func notifyNew(_ findings: [Finding]) {
        let content = UNMutableNotificationContent()
        content.title = "Un changement mérite votre attention"
        content.body = findings.map(\.title).joined(separator: " • ")
            + ". Ouvrez l'app pour comprendre les conséquences."
        content.sound = .default
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    /// Rappel hebdomadaire pour refaire la vérification manuelle (iOS ne permet pas de la faire automatiquement).
    static func setWeeklyReminder(enabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [weeklyID])
        guard enabled else { return }
        let content = UNMutableNotificationContent()
        content.title = "Point confidentialité"
        content.body = "Prenez 2 minutes pour revérifier profils, autorisations et appareils de votre compte."
        var comps = DateComponents(); comps.weekday = 1; comps.hour = 18
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: weeklyID, content: content, trigger: trigger))
    }

    // MARK: Rafraîchissement en arrière-plan (best effort : iOS décide quand l'exécuter, voire jamais)

    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
            scheduleRefresh()
            Task { @MainActor in
                ScanEngine.shared.scan()
                task.setTaskCompleted(success: true)
            }
        }
    }

    static func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 3600)
        try? BGTaskScheduler.shared.submit(request)
    }
}
