import SwiftUI
import Charts

// Model to represent food data for the chart
struct FoodData {
    let category: String
    let value: Double
    let color: Color
}

// The main Stats View
struct StatsView: View {
    // Properties representing the stats to display
    var carbonEmissionReduced: Double = 52.6 // Replace with actual logic
//    var foodItemsNearExpiration: Int = 10 // Number of items nearing expiration
    var nonExpiredItemCount: Int{
        return foodsExpirationDate.count
    }
    var expiredItemCount: Int {
        return exp_item.count
    }
    
    // Food data for the pie chart
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                let totalItemCount = nonExpiredItemCount + expiredItemCount
                StatItemView(title: "Total Food Items Scanned", value: "\(totalItemCount)")
                                
                                
                                StatItemView(title: "Items Already Expired", value: "\(expiredItemCount)")
                // Carbon Emission Reduced
                StatItemView(title: "Carbon Emission Reduced", value: "\(carbonEmissionReduced) kg CO₂")

                
                // Food Items Near Expiration
//                StatItemView(title: "Items Near Expiration", value: "\(foodItemsNearExpiration)")
                
                // Pie Chart for Food Stats
                Text("Food Consumption vs. Waste")
                    .font(.headline)
                
                let foodData = [
                    FoodData(category: "Consumed", value: Double(nonExpiredItemCount), color: .green),
                    FoodData(category: "Wasted", value: Double(expiredItemCount), color: .red)
                ]
                
                // Creating the pie chart
                HollowPieChartView(data: foodData)
                    .frame(width: 200, height: 200)
            }
            .padding()
        }
        .navigationTitle("Stats")
    }
}

// View for individual stat item
struct StatItemView: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// Custom view for the hollow pie chart
struct HollowPieChartView: View {
    var data: [FoodData]
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(data, id: \.category) { item in
                    SectorMark(
                        angle: .value("Value", item.value),
                        innerRadius: .ratio(0.6),
                        outerRadius: .ratio(0.9)
                    )
                    .foregroundStyle(item.color)
                    .opacity(0.7)
                }
            }
            .chartLegend(.hidden) // Hides the default legend
            
            // Inner white circle to create hollow effect
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
            
            // Total percentage text in the middle of the pie chart
            VStack {
                Text("\(totalPercentage(), specifier: "%.1f")%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("Consumed")
                    .font(.caption)
            }
        }
    }
    
    // Calculate total percentage of food consumed
    private func totalPercentage() -> Double {
        let consumed = data.first { $0.category == "Consumed" }?.value ?? 0
        let total = data.reduce(0) { $0 + $1.value }
        return total > 0 ? (consumed / total) * 100 : 0
    }
}

// Preview for SwiftUI Previews
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
//all lifetime values
//number of items scanned - total- expired and non-expired
// number of items already expired
// number of expired vs non expired - how mnay you used isntead of wasting
// if anything was added to expired, we add it to num of items already expired
//if anything was added to to fooditems then we add to the non expired list
