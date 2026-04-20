import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for item: ClaimItem) {
        guard item.notificationEnabled else { return }

        let center = UNUserNotificationCenter.current()
        cancelNotification(for: item)

        // 1 month before
        let oneMonthBefore = Calendar.current.date(byAdding: .day, value: -30, to: item.expirationDate)
        if let d = oneMonthBefore, d > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-30",
                title: "📅 Warranty Expiring Soon",
                body: "\(item.itemName) warranty expires in 1 month.",
                date: d
            )
        }

        // 1 week before
        let oneWeekBefore = Calendar.current.date(byAdding: .day, value: -7, to: item.expirationDate)
        if let d = oneWeekBefore, d > Date() {
            scheduleNotification(
                id: "\(item.id.uuidString)-7",
                title: "⚠️ Warranty Ending Soon",
                body: "\(item.itemName) warranty expires in 1 week!",
                date: d
            )
        }
    }

    func cancelNotification(for item: ClaimItem) {
        let ids = ["\(item.id.uuidString)-30", "\(item.id.uuidString)-7"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
