//
//  StorageManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/17/24.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    private var eventImageReference: StorageReference {
        storage.child("event_images")
    }

    private var userImageReference: StorageReference {
        storage.child("user_images")
    }

    func getPathforImage(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }

    func getData(path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 4 * 1024 * 1024)
    }
    
    func getImage(path: String) async throws -> UIImage {
        let data = try await getData(path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    func getURLForPath(path: String) async throws -> URL {
        return try await Storage.storage().reference(withPath: path).downloadURL()
    }
    //Thru Data
    func saveEventImage(data: Data) async throws -> (path: String, name: String){
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await eventImageReference.child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
        
    }
    
    func saveUserImage(data: Data) async throws -> (path: String, name: String){
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userImageReference.child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
        
    }
    
    //Thru UIImage
    func saveImage(image: UIImage) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0) else {
            throw URLError(.unknown)
        }
        return try await saveEventImage(data: data)
    }
    
    func deleteImage(path: String) async throws{
        try await getPathforImage(path: path).delete()
    }
}
