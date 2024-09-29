import SwiftUI
import AVFoundation

import Foundation

struct ProductResponse: Codable {
    let product: Product?
}

struct Product: Codable {
    let productName: String?
    let brands: String?
    let imageUrl: String?  // Add this to retrieve the image URL
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageUrl = "image_front_small_url"  // Map to the correct API field
    }
}

struct PackageView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: PackageView
        
        init(parent: PackageView) {
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                // Print scanned barcode to the console
                print("Scanned Barcode: \(stringValue)")
                
                // Fetch product info based on the scanned barcode
                fetchProductInfo(barcode: stringValue)
                
                parent.didFindCode(stringValue)
            }
        }
    }

    var didFindCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

func fetchProductInfo(barcode: String) {
    let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching product info: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            print("No data returned")
            return
        }

        do {
            let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
            if let product = productResponse.product {
                // Print product name
                if let productName = product.productName {
                    print("Product Name: \(productName)")
                } else {
                    print("Product name not found for barcode: \(barcode)")
                }

                // Print brands
                if let brands = product.brands {
                    print("Brand(s): \(brands)")
                } else {
                    print("Brand name not found for barcode: \(barcode)")
                }

                // Print image URL
                if let imageUrl = product.imageUrl {
                    print("Image URL: \(imageUrl)")
                } else {
                    print("Image URL not found for barcode: \(barcode)")
                }
            } else {
                print("Product not found for barcode: \(barcode)")
            }
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
        }
    }.resume()
}


struct PackageTabView: View {
    @Binding var scannedCode: String?
    @Binding var productName: String?
    @Binding var productImageUrl: String?
    @Binding var expirationDate: Date
    @Binding var brandName: String? // Uncommented

    var body: some View {
        VStack {
            if let productName = productName, let productImageUrl = productImageUrl {
                VStack {
                    // Show product name
                    Text("Product: \(productName)")
                        .font(.title3)
                        .padding()
                    
                    // Show brand name
                    if let brandName = brandName {
                        Text("Brand: \(brandName)")
                            .font(.subheadline)
                            .padding()
                    }

                    // Show product image
                    if let url = URL(string: productImageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                 .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200, height: 200)
                        .padding()
                    } else {
                        Text("No Image Available")
                    }

                    // Date picker for expiration date
                    Text("Select Expiration Date")
                    DatePicker(
                        "",
                        selection: $expirationDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()

                    Spacer() // Push buttons to the bottom

                    // Confirm and Cancel buttons at the bottom
                    HStack {
                       Button(action: {
                           // Handle cancel action
                           resetScanner()
                       }) {
                           Text("Cancel")
                               .foregroundColor(.red)
                               .padding()
                               .frame(maxWidth: .infinity)
                               .background(Color.gray.opacity(0.2))
                               .cornerRadius(8)
                       }
                       .padding()

                       Button(action: {
                           // Handle confirm ction
                           print("Confirmed with expiration date: \(expirationDate)")
                           resetScanner() // Optionally reset after confirmation
                       }) {
                           Text("Confirm")
                               .foregroundColor(.white)
                               .padding()
                               .frame(maxWidth: .infinity)
                               .background(Color.blue)
                               .cornerRadius(8)
                       }
                       .padding()
                   }
                }
            } else {
                PackageView { code in
                    self.scannedCode = code
                    // Fetch product info based on scanned code
                    fetchProductInfo(barcode: code)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }

    private func resetScanner() {
        scannedCode = nil
        productName = nil
        productImageUrl = nil
        brandName = nil // Reset brand name as well
    }

    func fetchProductInfo(barcode: String) {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching product info: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                if let product = productResponse.product {
                    DispatchQueue.main.async {
                        self.productName = product.productName
                        self.productImageUrl = product.imageUrl
                        self.brandName = product.brands // Update the brand name here
                    }
                } else {
                    print("Product not found for barcode: \(barcode)")
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}
