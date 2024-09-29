import SwiftUI

struct ItemSelectionView: View {
    @Binding var selectedItemType: String?

    var body: some View {
        VStack {
            Text("Select Item Type")
                .font(.largeTitle)
                .padding()

            Button(action: {
                selectedItemType = "packaged"
            }) {
                Text("Packaged Items")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                selectedItemType = "pre-packaged"
            }) {
                Text("Pre-Packaged Items")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Item Selection")
    }
}
