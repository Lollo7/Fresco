import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scanBarButton: UIButton!
    @IBOutlet weak var scanTextField: UITextField!
    let scannerViewController = PrePackagedScanController()
  
  override func viewDidLoad() {
      super.viewDidLoad()
      scannerViewController.delegate = self
    }
  
  @objc func scanBarTapped() {
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}

extension ViewController: PrePackagedScanViewDelegate {
    func didFindScannedText(text: String) {
      //Assigning the delegate to scanTextField
        scanTextField.text = text
    }
}
