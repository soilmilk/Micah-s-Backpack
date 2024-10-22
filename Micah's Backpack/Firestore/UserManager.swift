//
//  UserManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


//This is how you decode an object
struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
    
}
struct DBUser: Codable {
    let userId: String
    let email: String?
    let dateCreated: Date?
    var name: String?
    var imagePath: String?
    var isAdmin: Bool? = nil
    
    init(auth: AuthDataResultModel, name: String?, imagePath: String?) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.name = name
        self.imagePath = imagePath
    }
    
    init( 
        userId: String,
        email: String? = nil,
        dateCreated: Date? = nil,
        name: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        self.name = name
        self.imagePath = "event_images/default.jpeg"
    }
    
    /*
    func togglePremiumStatus() -> DBUser {
        let currentValue = isPremium ?? false
        return DBUser(
            userId: userId,
            email: email,
            photoURL: photoURL,
            dateCreated: dateCreated,
            isPremium: !currentValue)
    }
    
    mutating func togglePremiumStatus() {
        let currentValue = isPremium ?? false
        isPremium = !currentValue
    }
     */

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case dateCreated = "date_created"
        case name = "name"
        case imagePath = "image_path"
        case isAdmin = "is_admin"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        self.isAdmin = try container.decodeIfPresent(Bool.self, forKey: .isAdmin)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.imagePath, forKey: .imagePath)
        try container.encodeIfPresent(self.isAdmin, forKey: .isAdmin)

    }
   
    
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    var currentDBUser: DBUser?
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    //makes sure firestore encodes user values as snakeCase
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true)
        //Set firebase
        currentDBUser = try await getUser(userId: user.userId)
    }
    
    func deleteUser(user_id: String) async throws {
        try await userDocument(userId: user_id).delete()
    }
    
    func changeUserName(newName: String) async throws{
        let data: [String: Any] = [
            DBUser.CodingKeys.name.rawValue: newName
        ]
        try await userDocument(userId: currentDBUser?.userId ?? "").updateData(data)
        //Cached
        UserManager.shared.currentDBUser?.name = newName
    }
    
    func changeUserImagePath(imagePath: String) async throws{
        let data: [String: Any] = [
            DBUser.CodingKeys.imagePath.rawValue: imagePath
        ]
        try await userDocument(userId: currentDBUser?.userId ?? "").updateData(data)
        //Cached
        UserManager.shared.currentDBUser?.imagePath = imagePath
    }
    

    /*
    func createNewUser(authDataResultModel auth: AuthDataResultModel) async throws {
        var userData: [String: Any] = [
            "user_id": auth.uid,
            "date_created": Timestamp()
        ]
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoURL = auth.photoURL {
            userData["photo_url"] = photoURL
        }
        //update data = add data
        //if document does not exist, set data or "overwrite" data
        try await userDocument(userId: auth.uid).setData(userData, merge: false)
        
    }
     */
    
     
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }

    
    /*
    func updateUserPremiumStatus(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true, encoder: encoder)
    }
     */
    

    /*
    func getUser(userId: String) async throws -> DBUser {
        let snapshot =  try await userDocument(userId: userId).getDocument()
        
        guard let data = snapshot.data(),  let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
       
        let email = data["email"] as? String
        let photoURL = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DBUser(userId: userId, email: email, photoURL: photoURL, dateCreated: dateCreated)
    }
     */
}
