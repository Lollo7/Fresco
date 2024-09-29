import SwiftUI

struct ListView: View {
    let foodItems: [FoodItem]

    var body: some View {
        List(foodItems) { item in
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("Expires on \(formattedDate(item.expirationDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                // Optionally, add an icon indicating expiration status
                if isExpired(item.expirationDate) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                } else if isExpiringSoon(item.expirationDate) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            }
            .padding(.vertical, 5)
        }
        .listStyle(PlainListStyle())
    }

    // Helper functions
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func isExpired(_ date: Date) -> Bool {
        return Date() > date
    }

    func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: Date(), to: date).day {
            return days <= 5 && days >= 0
        }
        return false
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(foodItems: [
            FoodItem(name: "Milk", expirationDate: Date().addingTimeInterval(86400 * 3)),
            FoodItem(name: "Eggs", expirationDate: Date().addingTimeInterval(86400 * 10))
        ])
    }
}
