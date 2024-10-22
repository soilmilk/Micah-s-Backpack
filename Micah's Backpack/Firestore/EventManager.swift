//
//  UserManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct DBEvent: Codable, Identifiable, Hashable {
    //To be able to be looped through a list
    let id = UUID()
    
    //DB properties
    let event_id: String
    var image_path: String
    var name: String
    var start_date: Date
    var end_date: Date
    var description: String
    var address: String
    var cityStateZip: String
    var addressURL: String
    var userIdDict: [String: Int]
    var last_updated: Date
    var is_deleted: Bool
    
    init(
        event_id: String,
        image_path: String,
        name: String,
        description: String,
        address: String,
        cityStateZip: String,
        addressURL: String,
        userIdDict: [String: Int],
        start_date: Date,
        end_date: Date,
        lastUpdated: Date
    ) {
        self.event_id = event_id
        self.image_path = image_path
        self.name = name
        self.start_date = start_date
        self.end_date = end_date
        self.description = description
        self.address = address
        self.cityStateZip = cityStateZip
        self.addressURL = addressURL
        self.userIdDict = userIdDict
        self.last_updated = lastUpdated
        self.is_deleted = false
    }
    
    enum CodingKeys: String, CodingKey {
        case image_path = "image_path"
        case name = "name"
        case startDate = "start_date"
        case endDate = "end_date"
        case description = "description"
        case address = "address"
        case cityStateZip = "city_state_zip"
        case addressURL = "address_url"
        case userIdDict = "user_id_dict"
        case eventId = "event_id"
        case lastUpdated = "last_updated"
        case is_deleted = "is_deleted"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.image_path = try container.decode(String.self, forKey: .image_path)
        self.name = try container.decode(String.self, forKey: .name)
        self.start_date = try container.decode(Date.self, forKey: .startDate)
        self.end_date = try container.decode(Date.self, forKey: .endDate)
        self.description = try container.decode(String.self, forKey: .description)
        self.address = try container.decode(String.self, forKey: .address)
        self.cityStateZip = try container.decode(String.self, forKey: .cityStateZip)
        self.addressURL = try container.decode(String.self, forKey: .addressURL)
        self.userIdDict = try container.decode([String: Int].self, forKey: .userIdDict)
        self.event_id = try container.decode(String.self, forKey: .eventId)
        self.last_updated = try container.decode(Date.self, forKey: .lastUpdated)
        self.is_deleted = try container.decode(Bool.self, forKey: .is_deleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.image_path, forKey: .image_path)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.start_date, forKey: .startDate)
        try container.encode(self.end_date, forKey: .endDate)
        try container.encode(self.description, forKey: .description)
        try container.encode(self.address, forKey: .address)
        try container.encode(self.cityStateZip, forKey: .cityStateZip)
        try container.encode(self.addressURL, forKey: .addressURL)
        try container.encode(self.userIdDict, forKey: .userIdDict)
        try container.encode(self.event_id, forKey: .eventId)
        try container.encode(self.last_updated, forKey: .lastUpdated)
        try container.encode(self.is_deleted, forKey: .is_deleted)
    }
    
    static var archiveURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Events.plist")
    }
    
    static func saveToFile(events: [DBEvent]) {
        let propertyListEncoder = PropertyListEncoder()
        let encodedEvents = try? propertyListEncoder.encode(events)
        try! encodedEvents!.write(to: archiveURL, options: .noFileProtection)
    }

    static func resetPlistFile(){
        let propertyListEncoder = PropertyListEncoder()
        let emptyEvents: [DBEvent] = []
        let encodedEvents = try? propertyListEncoder.encode(emptyEvents)
        try! encodedEvents!.write(to: archiveURL, options: .noFileProtection)
        
        UserDefaults.standard.set(nil, forKey: "lastUpdatedDate")
    }
    
    static func loadFromFile() -> [DBEvent]? {
        let propertyListDecoder = PropertyListDecoder()
        
        guard let retrievedEventData = try? Data(contentsOf: archiveURL) else { return nil }
        guard let decodedEvents = try? propertyListDecoder.decode(Array<DBEvent>.self, from: retrievedEventData) else { return nil }
        return decodedEvents
    }
    

}

final class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    
    private let eventCollection = Firestore.firestore().collection("events")
    
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
    
    private func eventDocument(id: String) -> DocumentReference {
        eventCollection.document(id)
    }
    
    private func peopleDict(eventId: String) async throws -> [String: Int] {
        try await eventDocument(id: eventId).getDocument().data(as: DBEvent.self).userIdDict
    }

    func createNewEvent(event_id: String?, name: String, description: String, address: String, cityStateZip: String, address_url: String, start_date: Date, end_date: Date, image: String, userIdDict: [String: Int]) async throws -> Date  {
        let currentDate = Date()
        let tempId = event_id == nil ? eventCollection.document().documentID : event_id!
        let createdEvent = DBEvent(
            event_id: tempId,
            image_path: image,
            name: name,
            description: description,
            address: address,
            cityStateZip: cityStateZip,
            addressURL: address_url,
            userIdDict: userIdDict,
            start_date: start_date,
            end_date: end_date,
            lastUpdated: currentDate
            )
        
        try eventDocument(id: tempId).setData(from: createdEvent, merge: false)
        return currentDate
    }

    func deleteEventFromFireBase(eventId: String) {
        eventDocument(id: eventId).delete()
    }
    
    func replaceEventDeletedStatus(eventId: String) async throws {
        let data: [String: Any] = [
            DBEvent.CodingKeys.is_deleted.rawValue: true,
            DBEvent.CodingKeys.lastUpdated.rawValue: Date()
        ]
        try await eventDocument(id: eventId).updateData(data)
    }
    
    
    
    func signUpEvent(userId: String, eventId: String, numberOfPeople: Int?) async throws{
        var currentDict = try await peopleDict(eventId: eventId)
        currentDict[userId] = numberOfPeople
        
        let data: [String: Any] = [
            DBEvent.CodingKeys.userIdDict.rawValue: currentDict,
            DBEvent.CodingKeys.lastUpdated.rawValue: Date()
        ]
        try await eventDocument(id: eventId).updateData(data)
    }
    
    func cancelEvent(userId: String, eventId: String) async throws{
        var currentList = try await eventDocument(id: eventId).getDocument().data(as: DBEvent.self).userIdDict
        currentList[userId] = nil
        
        let data: [String: Any] = [
            DBEvent.CodingKeys.userIdDict.rawValue: currentList,
            DBEvent.CodingKeys.lastUpdated.rawValue: Date()
        ]
        try await eventDocument(id: eventId).updateData(data)
    }
    
    func getAllUpdatedEvents() async throws -> QuerySnapshot? {
        
        var updatedDate = Date(timeIntervalSince1970: 0)
        if let timestamp = UserDefaults.standard.object(forKey: "lastUpdatedDate") as? Timestamp {
            updatedDate = timestamp.dateValue()
        }

        return try await eventCollection
            .whereField("last_updated", isGreaterThan: updatedDate).getDocuments()
         
    }
    func getAllEvents() async throws -> [DBEvent] {
        let snapshot = try await eventCollection.getDocuments()
        
        var events: [DBEvent] = []
        for document in snapshot.documents {
            let event = try document.data(as: DBEvent.self)
            events.append(event)
        }
        return events
    }
    
    func getAllPeopleFromEvent(eventPeopleDict: [String: Int]) async throws -> [UserInfo] {
        if eventPeopleDict.isEmpty {
            return []
        }
        
    
        guard let result = try await AuthenticationManager.shared.getAllUserNames(userIds: Array(eventPeopleDict.keys)) else {
            return []
        }
        
        var resultList = [UserInfo]()
        for document in result.documents {
            let userId = document.data()[DBUser.CodingKeys.userId.rawValue] as? String ?? ""
            let userName = document.data()[DBUser.CodingKeys.name.rawValue]  as? String ?? ""
            let userPath = document.data()[DBUser.CodingKeys.imagePath.rawValue] as? String ?? "event_images/default.jpeg"
            resultList.append(
                UserInfo(
                    numOfGuests: eventPeopleDict[userId] ?? 0,
                    name: userName.replacingOccurrences(of: "|", with: " "),
                    path: userPath)
            )
            
        }
        
        return resultList
    }

   
}

struct UserInfo: Identifiable {
    let id = UUID()
    
    let numOfGuests: Int
    let userName: String
    let imagePath: String
    
    init(
        numOfGuests: Int,
        name: String,
        path: String
    ) {
        self.numOfGuests = numOfGuests
        self.userName = name
        self.imagePath = path
    }
}

