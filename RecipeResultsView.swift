import SwiftUI

struct RecipeResultsView: View {
    let recipes: [Recipe] // The list of recipes to display

    var body: some View {
        VStack {
            if recipes.isEmpty {
                Text("No recipes found.")
                    .font(.headline)
                    .padding()
            } else {
                List(recipes) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.label)
                            .font(.headline)
                        Text("Source: \(recipe.source)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if let imageUrl = URL(string: recipe.image) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        if !recipe.url.isEmpty{
                            Link("Go to recipe", destination: URL(string: "\(recipe.url)")!)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Recipe Results")
        .navigationBarTitleDisplayMode(.inline) // Back button is provided automatically
    }
}

struct RecipeResultsView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeResultsView(recipes: [])
    }
}
