import SwiftUI
import AVFoundation

struct BarcodeScanView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScanView
        
        init(parent: BarcodeScanView) {
            self.parent = parent
        }
        
//        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataMachineReadableCodeObject], from connection: AVCaptureConnection) {
//            if let metadataObject = metadataObjects.first {
//                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
//                guard let stringValue = readableObject.stringValue else { return }
//                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                parent.didFindCode(stringValue)
//            }
//        }
    }
    
//    var didFindCode: (String) -> Void

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
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
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

    struct ProductPopup: View {
        var productName: String
        var productImageUrl: String
        @Binding var isPresented: Bool
        @State private var expirationDate: Date = Date()

        var body: some View {
            VStack {
                Text(productName)
                    .font(.headline)
                AsyncImage(url: URL(string: productImageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                } placeholder: {
                    ProgressView()
                }
                DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                Button("Save") {
                    // Handle saving the expiration date here
                    isPresented = false
                }
                Button("Cancel") {
                    isPresented = false
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding()
        }
    }

    // Function to fetch product details from Open Food Facts API
    func fetchProductDetails(barcode: String, completion: @escaping (String, String?) -> Void) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(barcode)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching product data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let product = json["product"] as? [String: Any],
                   let productName = product["product_name"] as? String,
                   let imageUrl = product["image_url"] as? String {
                    DispatchQueue.main.async {
                        completion(productName, imageUrl)
                    }
                } else {
                    print("Product data not found.")
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
