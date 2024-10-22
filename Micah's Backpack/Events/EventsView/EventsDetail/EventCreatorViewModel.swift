//
//  EventCreatorViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/17/24.
//

import Foundation
import PhotosUI
import SwiftUI
import Combine
import CoreLocation
import MapKit


@MainActor class EventCreatorViewModel: ObservableObject {
    @Published var acceptSubmissions = true
    
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var addressURL: String = ""
    @Published var start_date = Date.now
    @Published var end_date = Date.now
    @Published var image_path: String = ""
    @Published var url: URL? = nil
    
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var selectedImage: Image?
    
    @Published var alertDescription = ""
    @Published var showAlert = false
    
    @Published var address = ""
    @Published var cityStateZip = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zip = ""
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var isFocusNeeded: Bool = true
    
    @State var btnHover = false
    @State var isBtnActive = false
    var updatedEvent: DBEvent? = nil
    
    
    func createNewEvent(event_id: String?, item: PhotosPickerItem?, userIdDict: [String: Int]) async throws -> Date?  {
        
        //If the user selects a new image; if they do not, image_path is untouched
        if let item = item {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                return nil
            }
            let (firebase_path, _) = try await StorageManager.shared.saveEventImage(data: data)
            
            let oldImagePath = image_path
            
            do {
                try await StorageManager.shared.deleteImage(path: oldImagePath)
            } catch {
                //Do nothing
            }
            
            self.image_path = firebase_path
        }
 
        return try await EventManager.shared.createNewEvent(
            event_id: event_id, name: name,
            description: description,
            address: address,
            cityStateZip: cityStateZip,
            address_url: addressURL,
            start_date: start_date,
            end_date: end_date,
            image: image_path,
            userIdDict: userIdDict)
        
    }
    
    @MainActor
    func showCurrentEventValues(event: DBEvent, mapSearch: MapSearch) async {
        self.name = event.name
        self.description = event.description
        self.address = event.address
        self.addressURL = event.addressURL
        self.cityStateZip = event.cityStateZip
        self.start_date = event.start_date
        self.end_date = event.end_date
        self.image_path = event.image_path
        
        //Load current Image
        do {
            self.url = try await StorageManager.shared.getURLForPath(path: event.image_path)
        } catch {
            alertDescription = "Failed to load current event image."
            showAlert = true
        }
        
        mapSearch.searchTerm = event.address
        let s = event.cityStateZip.components(separatedBy: "|")
        self.city = s[0]
        self.state = s[1]
        self.zip = s[2]
    }
    
    
    @MainActor
    func createOrEditEvent(isNewEvent: Bool, event: DBEvent) async -> Bool {
        //Check for fields
        guard !name.isEmpty && !description.isEmpty && !address.isEmpty, !addressURL.isEmpty else {
            alertDescription = "Please fill out all the fields!"
            showAlert = true
            return false
        }
        
        //Fixes creating duplicate events
        acceptSubmissions = false
        
        do {
            if (isNewEvent && selectedItem != nil) {
                //Creating a new Event
                guard let _ = try await createNewEvent(event_id: nil, item: selectedItem!, userIdDict: [:]) else {
                    alertDescription = "Failed to create the event."
                    showAlert = true
                    return false
                }
                return true
            } else if (!isNewEvent) {
                if (selectedItem != nil || url != nil) {
                    //Editing the Event.
                    //If the user sticks with the current image, selectedImage = nil
                    guard let currentDate = try await createNewEvent(event_id: event.event_id, item: selectedItem, userIdDict: event.userIdDict) else {
                        alertDescription = "Failed to update the event."
                        showAlert = true
                        return false
                    }
                    
                    //After creating the event, update the CACHED event, not fb
                    updatedEvent = DBEvent(event_id: event.event_id, image_path: event.image_path, name: name, description: description, address: address, cityStateZip: cityStateZip, addressURL: addressURL, userIdDict: event.userIdDict, start_date: start_date, end_date: end_date, lastUpdated: currentDate)
                    
                    acceptSubmissions = true
                    return true
                }

                
            } else {
                alertDescription = "Please upload an image for the event."
                showAlert = true
                acceptSubmissions = true
                return false
            }
        } catch {
            alertDescription = "\(error)"
            showAlert = true
        }
        acceptSubmissions = true
        return false
        
    }
    
    func reverseGeo(location: MKLocalSearchCompletion, mapSearch: MapSearch) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }
            
            if let c = coordinateK {
                self.location = c
                
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        DispatchQueue.main.async {
                            self.alertDescription = "There was an error searching a location."
                            self.showAlert = true
                        }
                        return
                    }
                    
                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    self.address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
                    self.cityStateZip = "\(reversedGeoLocation.city)|\(reversedGeoLocation.state)|\(reversedGeoLocation.zipCode)"
                    self.addressURL = "maps://?saddr=&daddr=\(c.latitude),\(c.longitude)"
                    self.city = "\(reversedGeoLocation.city)"
                    self.state = "\(reversedGeoLocation.state)"
                    self.zip = "\(reversedGeoLocation.zipCode)"
                    mapSearch.searchTerm = self.address
                    self.isFocusNeeded = false
                    
                }
            }
        }
    }
    
    
}
