import SwiftUI

struct ClaimRow: View {
    let item: ClaimItem

    var body: some View {
        HStack(spacing: 14) {
            Text(item.categoryIcon)
                .font(.title)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(item.storeName.isEmpty ? "Unknown store" : item.storeName)
                    Text("·")
                    Text(item.formattedPurchaseDate)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.statusText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(item.statusColor)

                Text(item.warrantyMonths == 1 ? "1 mo" : "\(item.warrantyMonths) mo")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ClaimRow(item: ClaimItem(
        itemName: "MacBook Pro",
        storeName: "Apple Store",
        category: "Electronics",
        purchaseDate: Date().addingTimeInterval(-86400 * 300),
        warrantyMonths: 24
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
}
