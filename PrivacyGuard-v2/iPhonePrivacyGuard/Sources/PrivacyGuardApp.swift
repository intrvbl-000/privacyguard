import SwiftUI
import BackgroundTasks

@main
struct PrivacyGuardApp: App {
    @StateObject private var engine = ScanEngine.shared
    @AppStorage("appearance") private var appearance = Appearance.system.rawValue
    @Environment(\.scenePhase) private var phase

    init() { AlertService.registerBackgroundTask() }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(engine)
                .preferredColorScheme(Appearance(rawValue: appearance)?.scheme)
                .task {
                    await AlertService.requestAuthorization()
                    engine.scan()
                }
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .active { engine.scan() }
            if newPhase == .background { AlertService.scheduleRefresh() }
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Tableau de bord", systemImage: "shield.lefthalf.filled") }
            AuditView()
                .tabItem { Label("Vérifier", systemImage: "checklist") }
            GuideView()
                .tabItem { Label("Autorisations", systemImage: "hand.raised") }
            AccountsView()
                .tabItem { Label("Comptes", systemImage: "person.badge.key") }
            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape") }
        }
        .tint(Theme.accent)
    }
}
