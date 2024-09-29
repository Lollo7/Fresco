import Foundation
import UIKit
import SwiftUI
import PhotosUI

struct GeminiRequest: Encodable {
    let contents: [Content]
}

struct Content: Encodable {
    let parts: [Part]
}

struct Part: Encodable {
    let text: String
}

// Define the response structures
struct GeminiResponse: Decodable {
    let candidates: [Candidate]
}

struct Candidate: Decodable {
    let content: ContentResponse
}

struct ContentResponse: Decodable {
    let parts: [PartResponse]
}

struct PartResponse: Decodable {
    let text: String
}

func callGeminiAPI(displayName: String) async throws -> String {
    guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyC39BJ6qdE9-7_UAKj4Xy_nrP1W5V7k5NI") else {
        throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Create the request body
    let requestBody = GeminiRequest(contents: [
        Content(parts: [
            Part(text: "I want your response to follow this format: <storage conditions>: <time to expiry in seconds> If I buy a \(displayName) today, how long will it last? Give me your best estimate and do not deviate from the response format I provided you with. Provide the most plausible storage options. Also your time to expiration should be in seconds only. The response should be in JSON format with key called 'storage_type' and value the storage option and another key called 'duration' and value time to expirty in seconds. Return only the dictionary. Start your response at the first curly brace and end with a closing curly brace. Like this {'storage_type': <storage_type>, 'duration': <duration in seconds>}")
        ])
    ])
    
    // Encode the request body to JSON
    let jsonData = try JSONEncoder().encode(requestBody)
    request.httpBody = jsonData

    // Send the request
    let (data, response) = try await URLSession.shared.data(for: request)

    // Check for HTTP response status
    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        let errorResponse = String(data: data, encoding: .utf8)
        print("Error response: \(errorResponse ?? "No error message")")
        throw URLError(.badServerResponse)
    }

    // Decode the response
    let responseData = try JSONDecoder().decode(GeminiResponse.self, from: data)
    
    // Extract the text from the first candidate
    guard let firstCandidate = responseData.candidates.first,
          let firstPart = firstCandidate.content.parts.first else {
        throw URLError(.cannotDecodeContentData)
    }

    return firstPart.text
}


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

struct FoodResponse: Codable {
    let items: [Item]
}

struct Item: Codable {
    let food: [FoodElement]
}

struct FoodElement: Codable {
    let confidence: Double
    let foodInfo: FoodInfo

    enum CodingKeys: String, CodingKey {
        case confidence
        case foodInfo = "food_info"
    }
}

struct FoodInfo: Codable {
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
    }
}

struct GeminiAPIResponse: Decodable {
    let storageType: String
    let duration: Int
    
    enum CodingKeys: String, CodingKey {
        case storageType = "storage_type"
        case duration
    }
}

func getDisplayName(from jsonData: Data) -> String? {
    do {
        let decodedResponse = try JSONDecoder().decode(FoodResponse.self, from: jsonData)
        // Access the first item and its food's display name (most confident is index 0)
        return decodedResponse.items.first?.food.first?.foodInfo.displayName
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

var foodItemName: String = ""
var storageInformation: String = ""
var expirationInformation: Int = 0

@MainActor
class NetworkManager: ObservableObject {
    @Published var foodName: String = ""
    @Published var storageInfo: String = ""
    @Published var expirationInfo: Int = 0
    @Published var calories: Float = 0.0
    @Published var servingSize: Float = 0.0
    @Published var fvGrade: String = ""
    
    func analyzeImage(_ image: UIImage) {
        guard let url = URL(string: "https://vision.foodvisor.io/api/1.0/en/analysis/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the authorization header with the API key
        let apiKey = "zgLlkLCX.P7AJVpYAChqmuJGUQlbNKb8TBd1bXOiC"
        request.setValue("Api-Key \(apiKey)", forHTTPHeaderField: "Authorization")

        // Boundary string to separate form fields
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the multipart form data body
        var body = Data()
        
        // Compress the image using your JPEGQuality extension
        let maxFileSize = 2 * 1024 * 1024 // 2MB
        
        // Start with high quality
        let imageData = image.jpeg(.lowest)
        
        // Adjust if the image exceeds the 2MB limit
        if var compressedImageData = imageData, compressedImageData.count > maxFileSize {
            // Use a lower quality if the image is too large
            compressedImageData = image.jpeg(.medium)!
            
            // Further reduce to lowest quality if still larger than 2MB
            if compressedImageData.count > maxFileSize {
                compressedImageData = image.jpeg(.low)!
            }
        }
        
        guard let finalImageData = imageData, finalImageData.count <= maxFileSize else {
            print("Error: Couldn't compress image to fit within 2MB limit")
            return
        }

        // Add the compressed image to the body as multipart data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(finalImageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End the multipart form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Create and execute the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Request failed with error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let displayName = getDisplayName(from: data) {
                print("\(displayName)")
                Task { @MainActor in
                    do {
                        let responseText = try await callGeminiAPI(displayName: displayName)
                        self?.foodName = displayName
                        print("Response from Gemini API: \(responseText)")
                        if let responseData = responseText.data(using: .utf8) {
                            let geminiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: responseData)
                            self?.storageInfo = geminiResponse.storageType
                            self?.expirationInfo = geminiResponse.duration
                        }
                    } catch {
                        print("Failed to call Gemini API: \(error)")
                    }
                }
            } else {
                print("Failed to extract display name.")
            }
        }.resume()
    }
}

// Helper function to append data to a Data object
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct Food: Codable {
    let foodID: String
    let displayName: String
    let servingSizeInGrams: Double
    let fvGrade: String?
    let nutrition: Nutrition
}

struct Nutrition: Codable {
    let caloriesPer100g: Double?
    let proteinsPer100g: Double?
    let fatPer100g: Double?
    let carbsPer100g: Double?
    let fibersPer100g: Double?
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

struct ScanView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @StateObject private var networkManager = NetworkManager()
    @State private var showConfirmation = false

    var body: some View {
        VStack {
            // Display selected image or placeholder
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(Text("Tap to take a picture").foregroundColor(.gray))
                    .padding()
            }

            // Button to show the image picker
            Button(action: {
                showImagePicker = true
            }) {
                Text("Take Picture")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }

            // Analyze image button
            Button(action: {
                if let image = selectedImage {
                    networkManager.analyzeImage(image)
                    showConfirmation = true
                }
            }) {
                Text("Analyze Image")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .disabled(selectedImage == nil)
        }
        .navigationTitle("Scan Item")
        .sheet(isPresented: $showConfirmation) {
            ConfirmationView(
                foodName: networkManager.foodName,
                storageInfo: networkManager.storageInfo,
                expirationInfo: networkManager.expirationInfo,
                showConfirmation: $showConfirmation
            )
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}


struct ConfirmationView: View {
    let foodName: String
    let storageInfo: String
    let expirationInfo: Int
    @Binding var showConfirmation: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Confirm Food Details")
                .font(.title)
                .padding(.top)

            Text("Detected Food: \(foodName)")
            Text("Storage Type: \(storageInfo)")
            Text("Expiration Duration: \(Int(round(Double(expirationInfo)/86400))) days")
            
            HStack {
                Button("Cancel") {
                    showConfirmation = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Confirm") {
                    // Handle the confirmation action (e.g., save the food info)
                    showConfirmation = false
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .padding()
    }
}
