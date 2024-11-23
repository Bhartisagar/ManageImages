import UIKit
import AVFoundation
import RealmSwift

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    private func setupCamera() {
        checkCameraAuthorization { [weak self] authorized in
            guard authorized else {
                self?.showPermissionAlert()
                return
            }
            DispatchQueue.main.async {
                self?.startCameraSession()
            }
        }
    }

    private func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }

    private func startCameraSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }

        do {
            captureSession = AVCaptureSession()
            guard let captureSession = captureSession else { return }

            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            photoOutput = AVCapturePhotoOutput()
            guard let photoOutput = photoOutput else { return }
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            guard let videoPreviewLayer = videoPreviewLayer else { return }

            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)

            captureSession.startRunning()
        } catch {
            print("Error while setting up camera: \(error.localizedDescription)")
        }
    }

    private func setupUI() {
        // Capture Button
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        captureButton.center = CGPoint(x: view.frame.midX, y: view.frame.height - 100)
        captureButton.layer.cornerRadius = 35
        captureButton.backgroundColor = .red
        captureButton.layer.borderColor = UIColor.white.cgColor
        captureButton.layer.borderWidth = 3
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)

        // Back Button
        let backButton = UIButton(frame: CGRect(x: 20, y: 40, width: 60, height: 40))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        backButton.layer.cornerRadius = 5
        backButton.addTarget(self, action: #selector(backToMain), for: .touchUpInside)
        view.addSubview(backButton)
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error capturing photo: \(String(describing: error?.localizedDescription))")
            return
        }
        let capturedImage = UIImage(data: imageData)
        let previewVC = PreviewViewController()
        previewVC.capturedImage = capturedImage
        present(previewVC, animated: true, completion: nil)
    }

    @objc private func backToMain() {
        dismiss(animated: true, completion: nil)
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Permission Needed",
                                      message: "Please enable camera access in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        present(alert, animated: true)
    }
}
