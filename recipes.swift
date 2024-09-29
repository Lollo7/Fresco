import SwiftUI

struct RecipesView: View {
    @State private var expiringItems: [FoodItem] = [
        FoodItem(name: "Milk", expirationDate: Date().addingTimeInterval(86400)),
        FoodItem(name: "Tomatoes", expirationDate: Date().addingTimeInterval(86400 * 3)),
        FoodItem(name: "Bread", expirationDate: Date().addingTimeInterval(86400 * 2))
    ]
    @State private var otherItems: [FoodItem] = [
        FoodItem(name: "Eggs", expirationDate: Date().addingTimeInterval(86400 * 10)),
        FoodItem(name: "Butter", expirationDate: Date().addingTimeInterval(86400 * 12)),
        FoodItem(name: "Cheese", expirationDate: Date().addingTimeInterval(86400 * 15))
    ]

    @State private var selectedItems: [String] = []
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var showRecipeResults = false
    private let appId = "fa8ad263"
    private let apiKey = "1fbe38edb5a07e1beea375fbebad100e"

    var body: some View {
        NavigationStack {
            VStack {
                Text("Expiring Soon")
                    .font(.headline)
                    .padding()

                List(expiringItems) { item in
                    FoodItemRow(item: item, isSelected: selectedItems.contains(item.name)) {
                        toggleSelection(for: item.name)
                    }
                }

                Text("Other Items")
                    .font(.headline)
                    .padding()
                
                List(otherItems) { item in
                    FoodItemRow(item: item, isSelected: selectedItems.contains(item.name)) {
                        toggleSelection(for: item.name)
                    }
                }

                Button(action: fetchRecipes) {
                    Text("Get Recipes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)

                .navigationDestination(isPresented: $showRecipeResults) {
                    RecipeResultsView(recipes: recipes)
                }

                Spacer()
            }
            .navigationTitle("Recipes")
        }
    }

    private func toggleSelection(for item: String) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }

    private func fetchRecipes() {
        guard !selectedItems.isEmpty else { return }
        
        let ingredients = selectedItems.joined(separator: ",")
        let urlString = "https://api.edamam.com/search?q=\(ingredients)&app_id=\(appId)&app_key=\(apiKey)&from=0&to=10"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedRecipes = try JSONDecoder().decode(RecipeResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.recipes = decodedRecipes.hits.map { $0.recipe }
                        self.isLoading = false
                        self.showRecipeResults = true
                    }
                } catch {
                    print("Error decoding recipe data: \(error)")
                    isLoading = false
                }
            } else if let error = error {
                print("Error fetching recipes: \(error)")
                isLoading = false
            }
        }.resume()
    }
}


struct RecipeResponse: Decodable {
    let hits: [RecipeHit]
}

struct RecipeHit: Decodable {
    let recipe: Recipe
}


struct Recipe: Identifiable, Decodable {
    var id: String {
        return uri // Using `uri` as the unique identifier
    }
    let uri: String
    let label: String
    let image: String
    let source: String
    let url: String
    let yield: Int
    let dietLabels: [String]
    let healthLabels: [String]
    let ingredientLines: [String]
    let calories: Double
    let cuisineType: [String]?
    let mealType: [String]?
    let dishType: [String]?
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView()
    }
}
