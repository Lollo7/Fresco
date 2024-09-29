import Foundation
import SwiftUI
//how will i update in real time while we are viewing when we scan an item or it expires, etc.
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let expirationDate: Date
    
    // Computed property to format the expiration date
    var expirationDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short // Use your preferred date style
        formatter.timeStyle = .none
        return formatter.string(from: expirationDate)
    }
}

struct ExpiredItem: Identifiable {
    let id = UUID()
    let name: String
    let expirationDate: Date
    
    // Computed property to format the expiration date
    var expirationDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short // Use your preferred date style
        formatter.timeStyle = .none
        return formatter.string(from: expirationDate)
    }
}

struct FoodItemRow: View {
    let item: FoodItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text(item.expirationDateFormatted)
                .foregroundColor(.gray)
        }
//        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0) // Slight scaling effect on selection
        .animation(.easeInOut, value: isSelected) // Smooth animation
        .onTapGesture {
            onTap()
        }
    }
}

struct ExpiredItemRow: View {
    let item: ExpiredItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text(item.expirationDateFormatted)
                .foregroundColor(.red)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0) // Slight scaling effect on selection
        .animation(.easeInOut, value: isSelected) // Smooth animation
        .onTapGesture {
            onTap()
        }
    }
}

struct HomeView: View {
    let userName: String = "Akshat"

    // Food items fetched from createFoodExpirationDates()
    @State private var foodItems: [FoodItem] = []
    @State private var expiredItems: [ExpiredItem] = []

    // Toggle state: true for list view, false for calendar view
    @State private var isListView: Bool = true

    // Custom initializer
    init() {
        // Initialize foodItems and expiredItems
        self._foodItems = State(initialValue: foodsExpirationDate.map { FoodItem(name: $0.key, expirationDate: $0.value) })
        self._expiredItems = State(initialValue: exp_item.map { ExpiredItem(name: $0.key, expirationDate: $0.value) })
    }

    struct ListView: View {
        @Binding var foodItems: [FoodItem]
        @Binding var expiredItems: [ExpiredItem]

        var body: some View {
            VStack(alignment: .leading) {
                if !expiredItems.isEmpty {
                    List {
                        Section(header: Text("Expired Items").font(.headline)) {
                            ForEach(expiredItems) { item in
                                ExpiredItemRow(item: item, isSelected: false, onTap: {})
                            }
                            .onDelete(perform: deleteExpiredItems)
                        }
                    }
                }

                List {
                    Section(header: Text("Current Items").font(.headline)) {
                        ForEach(foodItems) { item in
                            FoodItemRow(item: item, isSelected: false, onTap: {})
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
        }
        
        private func deleteItems(at offsets: IndexSet) {
            foodItems.remove(atOffsets: offsets)
        }
        
        private func deleteExpiredItems(at offsets: IndexSet) {
            expiredItems.remove(atOffsets: offsets)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Hello, \(userName)!")
                    .font(.largeTitle)
                    .padding(.top, 20)

                Picker("View Mode", selection: $isListView) {
                    Text("List").tag(true)
                    Text("Calendar").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isListView {
                    ListView(foodItems: $foodItems, expiredItems: $expiredItems)
                } else {
                    CalendarView(foodItems: foodItems)
                }

                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
