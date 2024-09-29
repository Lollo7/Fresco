import Foundation

func createFoodExpirationDates() -> [String: Date] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    var foodsExpirationDate: [String: Date] = [:]
    
    if let milkDate = dateFormatter.date(from: "2024-10-08") {
        foodsExpirationDate["Milk"] = milkDate
    }
    if let eggsDate = dateFormatter.date(from: "2024-10-15") {
        foodsExpirationDate["Eggs"] = eggsDate
    }
    if let cheeseDate = dateFormatter.date(from: "2024-10-02") {
        foodsExpirationDate["Cheese"] = cheeseDate
    }
    if let breadDate = dateFormatter.date(from: "2024-10-04") {
        foodsExpirationDate["Bread"] = breadDate
    }
    return foodsExpirationDate
}

// Call the function to create the dictionary
let foodsExpirationDate = createFoodExpirationDates()

func expiredItemsArray() -> [String: Date] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    var exp_items: [String: Date] = [:]
    
    if let yoghurtDate = dateFormatter.date(from: "2023-10-08") {
        exp_items["Yoghurt"] = yoghurtDate
    }
    if let milkDate = dateFormatter.date(from: "2023-08-08") {
        exp_items["Spoiled Milk"] = milkDate
    }
    return exp_items
}

let exp_item = expiredItemsArray()
