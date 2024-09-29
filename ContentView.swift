import SwiftUI

struct ContentView: View {
    // State variable to control the alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var scannedCode: String?
    @State private var productName: String?
    @State private var productImageUrl: String?
    @State private var expirationDate = Date()
    @State private var brandName: String?

    var body: some View {
        TabView {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // Recipes Tab
            RecipesView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }

            // Scan Tab
            ScanView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Scan")
                }
            
            PackageTabView(scannedCode: $scannedCode,
                           productName: $productName,
                           productImageUrl: $productImageUrl,
                           expirationDate: $expirationDate,
                           brandName: $brandName
                       )
                       .tabItem {
                           Image(systemName: "camera.viewfinder")
                           Text("Barcode")
                       }

            // Stats Tab
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }

            // Account Tab
            AccountView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Account")
                }
        }
        .accentColor(.green) // Optional: Change the tint color of the selected tab
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
