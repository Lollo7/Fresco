import SwiftUI

struct CalendarView: View {
    let foodItems: [FoodItem]

    // Generate the current month's dates
    @State private var currentDate: Date = Date()
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack {
            // Month and Year Header with Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text(monthYearString(from: currentDate))
                    .font(.headline)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding()

            // Today Button to Navigate to Current Month
            Button(action: goToToday) {
                Text("Today")
                    .font(.subheadline)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 20)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }

            // Days of the Week Header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 5)

            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { date in
                    VStack(alignment: .leading) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.body)
                            .padding(5)
                            .background(isToday(date) ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(5)

                        // Filter food items expiring on this date
                        let items = foodItems.filter { Calendar.current.isDate($0.expirationDate, inSameDayAs: date) }

                        if !items.isEmpty {
                            ForEach(items) { item in
                                Text(item.name)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(isWeekend(date) ? Color.gray.opacity(0.1) : Color.clear)
                    .cornerRadius(5)
                }
            }
            .padding(.horizontal)
        }
    }

    // Helper Functions
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    func goToToday() {
        currentDate = Date()
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }

    func isWeekend(_ date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // Sunday = 1, Saturday = 7
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(foodItems: [
            FoodItem(name: "Milk", expirationDate: Date()),
            FoodItem(name: "Bread", expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!),
            FoodItem(name: "Yogurt", expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
        ])
    }
}
