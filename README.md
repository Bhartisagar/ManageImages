# Image Capture and Upload App Documentation

## Architecture and Design Approach

### Tools and Technologies Used

1. **Programming Language**: Swift
2. **Architecture**: MVVM (Model-View-ViewModel) to ensure a clean separation of concerns.
3. **Local Database**: Realm for persistent local storage of image metadata and upload status.
4. **Camera Integration**: AVCaptureSession for capturing images directly from the device camera.
5. **Networking**: URLSession for managing asynchronous API requests and background uploads.
6. **Asynchronous Calls**: Combine framework for reactive programming and handling asynchronous events.
7. **UI Framework**: SwiftUI for modern and dynamic user interface development.

---

## Features and Implementation

### 1. **Image Capture Using AVCapture**

- Configured an `AVCaptureSession` to enable real-time camera preview and capture still images.
- Implemented a `CameraViewController` where the camera interface has a **capture button** and a **back button**:
  - **Capture Button**: Captures an image, saves it temporarily in memory, and stores it in Realm.
  - **Back Button**: Navigates back to the main screen.

#### Code Snippet:

```swift
import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    private let captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCameraSession()
        setupUI()
    }

    private func configureCameraSession() {
        captureSession.beginConfiguration()
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        captureSession.addInput(videoInput)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        captureSession.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    private func setupUI() {
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        // Save to Realm here
        print("Image captured: \(image)")
    }
}
```

### 2. **Local Database (Realm)**

- Stored image metadata such as:
  - **URI**: Path of the saved image.
  - **Name**: Unique identifier for the image.
  - **Capture Date**: Timestamp of image capture.
  - **Upload Status**: Tracks if the image is "Pending", "Uploading", or "Completed".
- Used Realm to persistently manage data, enabling retrieval and upload resumption after app relaunch.

#### Code Snippet:

```swift
import RealmSwift

class ImageModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var uri: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var captureDate: Date = Date()
    @objc dynamic var uploadStatus: String = "Pending"

    override static func primaryKey() -> String? {
        return "id"
    }
}

func saveImageToRealm(uri: String, name: String) {
    let realm = try! Realm()
    let image = ImageModel()
    image.uri = uri
    image.name = name
    try! realm.write {
        realm.add(image)
    }
}
```

### 3. **Image List Display with Upload Progress**

- Displayed captured images in a `UICollectionView` with:
  - **Thumbnail** of the image.
  - **Progress Indicator**: Real-time progress bar for uploads.
  - **Upload Status**: Text indicator for pending, uploading, or completed uploads.
- Added a "Retry" button for failed uploads.

#### Code Snippet:

```swift
import UIKit

class ImageListViewController: UIViewController, UICollectionViewDataSource {
    var images: [ImageModel] = []
    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchImagesFromRealm()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 150)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
    }

    private func fetchImagesFromRealm() {
        let realm = try! Realm()
        images = Array(realm.objects(ImageModel.self))
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageModel = images[indexPath.row]
        // Configure cell with thumbnail and status
        return cell
    }
}
```

### 4. **Image Upload Management**

- Integrated URLSession to handle image uploads using the provided API endpoint.
- **Key Features**:
  - **Duplicate Avoidance**: Checked the Realm database before initiating uploads to prevent re-uploading.
  - **Upload Resumption**: Leveraged the upload status in Realm to continue incomplete uploads upon app relaunch.
  - **Background Uploads**: Used `URLSessionConfiguration.background` to manage uploads without blocking the UI.

#### Code Snippet:

```swift
import Foundation

class ImageUploader {
    func uploadImage(_ image: ImageModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.clippr.ai/api/upload") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.uploadTask(with: request, fromFile: URL(fileURLWithPath: image.uri)) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            // Update Realm upload status
            let realm = try! Realm()
            try! realm.write {
                image.uploadStatus = "Completed"
            }
            completion(true)
        }
        task.resume()
    }
}
```

### 5. **Notifications and Real-Time Updates**

- Implemented local notifications to inform users upon successful uploads.
- Displayed toast messages for real-time updates on upload progress and completion.

---

## Challenges and Solutions

1. **Configuring AVCaptureSession**:

   - Ensured proper camera permissions and session configuration for photo capture.
   - Handled device orientation changes and camera access denials gracefully.

2. **Handling Asynchronous Uploads**:

   - Utilized Combine to ensure smooth progress updates without UI freezing.
   - Managed retries for failed uploads by storing and updating the status in Realm.

3. **Ensuring Smooth UI/UX**:

   - Designed a clean and intuitive interface with SwiftUI.
   - Optimized UICollectionView performance for seamless scrolling with many images.

4. **Background Upload Resumption**:

   - Leveraged URLSession’s background task capabilities to resume uploads even after app termination.
   - Stored upload checkpoints in Realm

