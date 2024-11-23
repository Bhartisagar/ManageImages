import Foundation
import RealmSwift

class ImageUploader: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    static let shared = ImageUploader()
    var session: URLSession!

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.yourapp.upload")
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func uploadImage(image: CapturedImage) {
        guard image.uploadStatus == "Pending" || image.uploadStatus == "Failed" else {
            return
        }
        
        let imageData = image.imageData
        // Upload the image to your server
        var request = URLRequest(url: URL(string: "https://www.clippr.ai/api/upload")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let uploadTask = session.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("Upload failed: \(error)")
                self.updateUploadStatus(image: image, status: "Failed", progress: 0)
                return
            }

            // Handle success
            self.updateUploadStatus(image: image, status: "Completed", progress: 1.0)
        }
        
        uploadTask.resume()
    }

    func updateUploadStatus(image: CapturedImage, status: String, progress: Float) {
        let realm = try! Realm()
        try! realm.write {
            image.uploadStatus = status
            image.uploadProgress = progress
        }
    }

    // MARK: - URLSessionDelegate Methods

    // Called when the session receives a response to the upload request
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Handle SSL challenges (optional)
        completionHandler(.performDefaultHandling, nil)
    }

    // Called when the task is finished with data (successful or failed)
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Upload task failed with error: \(error)")
        } else {
            print("Upload task completed successfully")
        }
    }

    // Called to track upload progress
    func urlSession(_ session: URLSession, uploadTask: URLSessionUploadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // Update progress in the Realm database
        if let image = getImage(for: uploadTask) {
            updateUploadStatus(image: image, status: "Uploading", progress: progress)
        }
    }

    // MARK: - Helper Methods
    
    // You might want to associate an image with the upload task,
    // possibly using a dictionary or another approach depending on your needs.
    func getImage(for task: URLSessionUploadTask) -> CapturedImage? {
        // Retrieve the image object associated with the task (if necessary)
        return nil
    }
}
