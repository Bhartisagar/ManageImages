//
//  PreviewViewController.swift
//  ManageImages
//
//  Created by Bharti Sagar on 22/11/24.
//
import UIKit
import RealmSwift

class PreviewViewController: UIViewController {
    var capturedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard let image = capturedImage else { return }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)

        // Save Button
        let saveButton = UIButton(frame: CGRect(x: 20, y: view.frame.height - 100, width: 100, height: 40))
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .green
        saveButton.layer.cornerRadius = 5
        saveButton.addTarget(self, action: #selector(saveImageToDatabase), for: .touchUpInside)
        view.addSubview(saveButton)

        // Close Button
        let closeButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: 40, width: 80, height: 40))
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(closePreview), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    @objc private func saveImageToDatabase() {
        guard let image = capturedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data.")
            return
        }

        let realm = try! Realm()
        
        let allCapturedImages = realm.objects(CapturedImage.self)
        let nextImageName = "image_\(allCapturedImages.count + 1)"
        
        let capturedImageObject = CapturedImage()
        capturedImageObject.imageName = nextImageName
        capturedImageObject.imageData = imageData

        do {
            try realm.write {
                realm.add(capturedImageObject)
            }
            print("Image saved successfully!")
            showAlert(title: "Success", message: "Image saved to database.")
            let uploadManager = ImageUploadManager()
            uploadManager.uploadImage(imageData: imageData, fileName: nextImageName) { success in
            try! realm.write {
                    capturedImageObject.uploadStatus = success ? "Uploaded" : "Failed"
            }
            print("Sucess status", success)
            // Optionally notify the user of success or failure
            let message = success ? "Image uploaded successfully!" : "Failed to upload image."
                self.showAlert(title: success ? "Success" : "Error", message: message)
            }
        } catch {
            print("Error saving image to Realm: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to save image.")
        }
    }


    @objc private func closePreview() {
        dismiss(animated: true, completion: nil)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OKay", style: .default, handler: { _ in
            self.closePreview()
        }))
        present(alert, animated: true, completion: nil)
    }
}
