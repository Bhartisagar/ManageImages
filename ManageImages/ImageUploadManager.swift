import Foundation
import UIKit

class ImageUploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    var iscompleted : Bool = false
    func uploadImage(imageData: Data, fileName: String, completion: @escaping (Bool) -> Void) {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            print("url is", fileURL)
        } catch {
            print("Failed to write image data to file: \(error)")
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "https://www.clippr.ai/api/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "com.yourapp.upload")
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        let uploadTask = session.uploadTask(with: request, fromFile: fileURL)
        uploadTask.resume()
        DispatchQueue.global(qos: .background).async {
        let success = self.iscompleted
        sleep(3)
        DispatchQueue.main.async {
            completion(success)
        }
        }
    }
    
    // Delegate methods for URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Upload failed with error: \(error.localizedDescription)")
        } else {
            print("Upload completed successfully!")
            iscompleted = true
            NotificationManager.showNotification(message: "Your image has been uploaded successfully!")
        }
    }
    
    func urlSession(_ session: URLSession, uploadTask: URLSessionUploadTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print("Upload Progress: \(progress * 100)%")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("Received response data: \(data)")
    }
}
