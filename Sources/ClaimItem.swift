import Foundation
import SwiftData
import SwiftUI

@Model
final class ClaimItem {
    var id: UUID

    var itemName: String
    var storeName: String
    var category: String
    var purchaseDate: Date
    var warrantyMonths: Int

    @Attribute(.externalStorage)
    var receiptImageData: Data?

    var notificationEnabled: Bool

    var createdAt: Date

    init(
        id: UUID = UUID(),
        itemName: String,
        storeName: String = "",
        category: String = "Other",
        purchaseDate: Date = Date(),
        warrantyMonths: Int = 12,
        receiptImageData: Data? = nil,
        notificationEnabled: Bool = true
    ) {
        self.id = id
        self.itemName = itemName
        self.storeName = storeName
        self.category = category
        self.purchaseDate = purchaseDate
        self.warrantyMonths = warrantyMonths
        self.receiptImageData = receiptImageData
        self.notificationEnabled = notificationEnabled
        self.createdAt = Date()
    }

    var expirationDate: Date {
        Calendar.current.date(byAdding: .month, value: warrantyMonths, to: purchaseDate) ?? purchaseDate
    }

    var daysLeft: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: expirationDate)
        return Calendar.current.dateComponents([.day], from: today, to: expiry).day ?? 0
    }

    var isExpired: Bool { daysLeft < 0 }

    var isExpiringSoon: Bool { daysLeft >= 0 && daysLeft <= 30 }

    var statusText: String {
        let d = daysLeft
        if d < 0 { return "🔴 Expired" }
        if d == 0 { return "🔴 Expires today" }
        if d < 7 { return "🟡 \(d) day\(d == 1 ? "" : "s") left" }
        if d < 30 { return "🟡 \(d) days left" }
        let m = d / 30
        return "🟢 \(m) month\(m == 1 ? "" : "s") left"
    }

    var statusColor: Color {
        let d = daysLeft
        if d < 0 { return .red }
        if d < 7 { return .orange }
        if d < 30 { return .yellow }
        return .green
    }

    var categoryIcon: String {
        switch category {
        case "Electronics": return "📱"
        case "Appliances": return "🔌"
        case "Clothing": return "👕"
        case "Tools": return "🔧"
        default: return "📦"
        }
    }

    var formattedPurchaseDate: String {
        purchaseDate.formatted(date: .abbreviated, time: .omitted)
    }

    var formattedExpirationDate: String {
        expirationDate.formatted(date: .abbreviated, time: .omitted)
    }
}
