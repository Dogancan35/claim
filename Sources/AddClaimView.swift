import SwiftUI
import SwiftData
import VisionKit

struct AddClaimView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var itemName = ""
    @State private var storeName = ""
    @State private var category = "Electronics"
    @State private var purchaseDate = Date()
    @State private var warrantyMonths = 12
    @State private var showingScanner = false
    @State private var receiptData: Data?
    @State private var showingSuccess = false

    let categories = ["Electronics", "Appliances", "Clothing", "Tools", "Other"]

    let warrantyOptions = [1, 3, 6, 12, 24, 36, 48, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.viewfinder")
                            Text("Scan Receipt")
                            Spacer()
                            if receiptData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                } header: {
                    Text("Receipt Scanner")
                }

                Section {
                    TextField("Product Name", text: $itemName)
                    TextField("Store Name (optional)", text: $storeName)
                } header: {
                    Text("Product Info")
                }

                Section {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            HStack {
                                Text(iconFor(cat))
                                Text(cat)
                            }
                            .tag(cat)
                        }
                    }

                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)

                    Picker("Warranty Length", selection: $warrantyMonths) {
                        ForEach(warrantyOptions, id: \.self) { months in
                            Text(labelFor(months)).tag(months)
                        }
                    }
                } header: {
                    Text("Details")
                }
            }
            .navigationTitle("Add Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveClaim()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .sheet(isPresented: $showingScanner) {
                ReceiptScanner { result in
                    if let data = result {
                        receiptData = data.imageData
                        if let name = result?.productName, !name.isEmpty {
                            itemName = name
                        }
                        if let store = result?.storeName, !store.isEmpty {
                            storeName = store
                        }
                        if let date = result?.purchaseDate {
                            purchaseDate = date
                        }
                    }
                    showingScanner = false
                }
            }
            .alert("Claim Saved", isPresented: $showingSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(itemName) has been added with \(warrantyMonths) month warranty.")
            }
        }
    }

    func iconFor(_ category: String) -> String {
        switch category {
        case "Electronics": return "📱"
        case "Appliances": return "🔌"
        case "Clothing": return "👕"
        case "Tools": return "🔧"
        default: return "📦"
        }
    }

    func labelFor(_ months: Int) -> String {
        if months == 1 { return "1 month" }
        if months < 12 { return "\(months) months" }
        if months == 12 { return "1 year" }
        return "\(months / 12) years"
    }

    func saveClaim() {
        let item = ClaimItem(
            itemName: itemName,
            storeName: storeName,
            category: category,
            purchaseDate: purchaseDate,
            warrantyMonths: warrantyMonths,
            receiptImageData: receiptData
        )
        modelContext.insert(item)
        showingSuccess = true
    }
}

#Preview {
    AddClaimView()
        .modelContainer(for: ClaimItem.self, inMemory: true)
}
