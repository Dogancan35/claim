import SwiftUI
import SwiftData

struct ClaimDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: ClaimItem

    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Status card
                VStack(spacing: 12) {
                    Text(item.categoryIcon)
                        .font(.system(size: 50))

                    Text(item.itemName)
                        .font(.title.bold())

                    Text(item.statusText)
                        .font(.headline)
                        .foregroundStyle(item.statusColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(item.statusColor.opacity(0.15))
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)

                // Timeline
                VStack(spacing: 0) {
                    timelineRow(title: "Purchased", value: item.formattedPurchaseDate, icon: "bag.fill", color: .blue)
                    Divider().padding(.leading, 50)
                    timelineRow(title: "Warranty Expires", value: item.formattedExpirationDate, icon: "clock.fill", color: item.statusColor)
                    if item.isExpired {
                        Divider().padding(.leading, 50)
                        timelineRow(title: "Status", value: "Expired", icon: "xmark.circle.fill", color: .red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Details
                VStack(spacing: 12) {
                    detailRow(label: "Store", value: item.storeName.isEmpty ? "Unknown" : item.storeName)
                    Divider().padding(.leading, 0)
                    detailRow(label: "Category", value: "\(item.categoryIcon) \(item.category)")
                    Divider().padding(.leading, 0)
                    detailRow(label: "Warranty", value: "\(item.warrantyMonths) month\(item.warrantyMonths == 1 ? "" : "s")")
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Notifications
                VStack(spacing: 12) {
                    Toggle(isOn: $item.notificationEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                            Text("Expiry Reminders")
                        }
                    }
                    .tint(.orange)
                    .onChange(of: item.notificationEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.scheduleNotification(for: item)
                        } else {
                            NotificationManager.shared.cancelNotification(for: item)
                        }
                    }

                    Text("You'll be reminded 1 month and 1 week before expiry.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

                // Receipt preview
                if item.receiptImageData != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Receipt")
                            .font(.headline)
                        if let uiImage = UIImage(data: item.receiptImageData!) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }

                // Delete
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Claim")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Claim Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Claim?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(item)
            }
        } message: {
            Text("This will permanently delete the warranty for \(item.itemName).")
        }
    }

    func timelineRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        ClaimDetailView(item: ClaimItem(
            itemName: "MacBook Pro",
            storeName: "Apple Store",
            category: "Electronics",
            purchaseDate: Date().addingTimeInterval(-86400 * 300),
            warrantyMonths: 24
        ))
    }
    .modelContainer(for: ClaimItem.self, inMemory: true)
}
