//
//  CapturedImage.swift
//  ManageImages
//
//  Created by Bharti Sagar on 22/11/24.
//


import RealmSwift

class CapturedImage: Object {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var imageData: Data
    @Persisted var timestamp: Date = Date()
    
    @objc dynamic var imageName: String = "" // Name for the image
    @objc dynamic var captureDate: Date = Date() // Date when the image was captured
    @objc dynamic var uploadStatus: String = "Pending" // Upload status: "Pending", "Uploading", "Completed"
    @objc dynamic var uploadProgress: Float = 0.0 // Upload progress (0 to 1)
    
    @objc dynamic var fileName: String = ""
    @objc dynamic var progress: Float = 0.0 // 0.0 to 1.0
    @objc dynamic var uploadUrl: String = ""
    
    override static func primaryKey() -> String? {
        return "fileName"
    }
}
