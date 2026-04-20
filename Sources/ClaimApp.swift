import SwiftUI
import SwiftData
import UserNotifications

@main
struct ClaimApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([ClaimItem.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }

        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

struct ClaimApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
