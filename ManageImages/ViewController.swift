//import UIKit
//import UIKit
//
//class ViewController: UIViewController {
//    
//    var captureImageButton: UIButton!
//    var showImageButton: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Background color for better visibility
//        self.view.backgroundColor = .white
//        self.title = "Main Screen"
//
//        // Set up Capture Image Button
//        captureImageButton = UIButton(type: .system)
//        captureImageButton.setTitle("Capture Image", for: .normal)
//        captureImageButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
//        captureImageButton.addTarget(self, action: #selector(captureImageButtonTapped), for: .touchUpInside)
//        self.view.addSubview(captureImageButton)
//        
//        // Set up Show Image Button
//        showImageButton = UIButton(type: .system)
//        showImageButton.setTitle("Show Image", for: .normal)
//        showImageButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
//        showImageButton.addTarget(self, action: #selector(showImageButtonTapped), for: .touchUpInside)
//        self.view.addSubview(showImageButton)
//    }
//
//    @objc func captureImageButtonTapped() {
//        print("Capture Image button clicked")
//        let cameraVC = CameraViewController()
//        self.navigationController?.pushViewController(cameraVC, animated: true)
//    }
//    
//    @objc func showImageButtonTapped() {
//        print("Show Image button clicked")
//        // Placeholder for Show Image functionality
//    }
//}
import UIKit

class ViewController: UIViewController {
    
    var captureImageButton: UIButton!
    var showImageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color for better visibility
        self.view.backgroundColor = .white
        self.title = "Main Screen"

        // Set up Capture Image Button
        captureImageButton = UIButton(type: .system)
        captureImageButton.setTitle("Capture Image", for: .normal)
        captureImageButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        captureImageButton.addTarget(self, action: #selector(captureImageButtonTapped), for: .touchUpInside)
        self.view.addSubview(captureImageButton)
        
        // Set up Show Image Button
        showImageButton = UIButton(type: .system)
        showImageButton.setTitle("Show Image", for: .normal)
        showImageButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        showImageButton.addTarget(self, action: #selector(showImageButtonTapped), for: .touchUpInside)
        self.view.addSubview(showImageButton)
    }

    @objc func captureImageButtonTapped() {
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true, completion: nil)
    }
    
    @objc func showImageButtonTapped() {
        print("Show Image button clicked")
        let galleryVC = ImageGalleryViewController()
        present(galleryVC, animated: true, completion: nil)
    }

}
