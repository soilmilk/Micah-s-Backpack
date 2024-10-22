//
//  ItemManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/9/24.
//

import Foundation
import FirebaseFirestore



final class LocationManager {
    
    static let shared = LocationManager()
    private init() {}
    
    private let locations = Firestore.firestore().collection("locations")
 
    private func locationDocument(name: String) -> DocumentReference {
        locations.document(name)
    }
    
    private func locationDocument(id: String) -> DocumentReference {
        locations.document(id)
    }
    
    func getLocation(id: String) async throws -> DocumentSnapshot {
        try await locationDocument(id: id).getDocument()
    }
    
    func deleteLocation(id: String) async throws {
        try await locationDocument(id: id).delete()
    }
    
    func getAllLocations() async throws -> [DocumentSnapshot] {
        try await locations.getDocuments().documents
    }
    
    func createLocation(deadline: Date, goal: Int, lat: Double, lon: Double, address: String, type: Protein) async throws -> String {
        let tempId = locations.document().documentID
        let data: [String: Any] = [
            "location_id": tempId,
            "address": address,
            "lat": lat,
            "lon": lon,
            "goal": goal,
            "canned_soup": 0,
            "beans_&_franks": type == .beans_and_franks ? 0 : -1,
            "tuna":  type == .tuna ? 0 : -1,
            "canned_pasta": 0,
            "canned_chicken": type == .chicken ? 0 : -1,
            "juice": 0,
            "snacks": 0,
            "milk": 0,
            "oatmeal": 0,
            "mac_n_cheese": 0,
            "fruit_cups":  0,
            "peanut_butter": type == .peanut_butter ? 0 : -1,
            "canned_veggies": 0,
            "cereal_cups":  0,
            "deadline": deadline
        ]
        try await locations.document(tempId).setData(data, merge: false)
        return tempId
    }
    
    func updateItemValues(data: [String: Any], location_id: String) async throws {
        try await locationDocument(id: location_id).updateData(data)
    }
}
