//
//  MyBagViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/31/24.
//

import Foundation
import FirebaseFirestore
import _MapKit_SwiftUI

final class MyBagViewModel: ObservableObject {
    //MARK: Tabs
    @Published var selection: Tabs = .events
    //MARK: MyBagView
    @Published var selectedLocation: Location? = nil
    @Published var locationItems: [ItemData] = []
    @Published var value = 0.0
    @Published var currentAmount = 0
    @Published var urgentItems = 0
    @Published var displayedValue = 0
    @Published var goal = 1
    @Published var searchTerm = ""
    @Published var selectedItem: ItemData?
    @Published var doneLoading = false
    
    @Published var locationId = ""
    @Published var showUpdateView = false
    
    @Published var showTrackerView = false
    @Published var locations: [Location] = []
    
    @Published var showAlert = false
    @Published var description = ""
    
    
    @MainActor func checkDeepLink(url: URL) -> Bool {
        guard let deepLinkComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)?.host   else {
            return false
        }

        if deepLinkComponent == Tabs.tracker.rawValue {
            selection = .tracker
        } else if deepLinkComponent.components(separatedBy: "+")[0] == Tabs.tracker.rawValue {
            selection = .tracker
            
            getLocations() {
                if let loc = self.locations.first(where: {$0.doc.documentID == deepLinkComponent.components(separatedBy: "+")[1]}) {
                    self.selectedLocation = loc
                    self.showTrackerView = true
                } else {
                    self.showAlert = true
                    self.description = "Failed to locate the correct tracker."
                }
            }
            
            
        }
        return true
    }
    
    
    func startTimer() {
        value = Double(currentAmount)/Double(goal)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            if displayedValue < currentAmount {
                displayedValue += 1
            } else if displayedValue > currentAmount {
                displayedValue -= 1
            } else {
                timer.invalidate()
            }
        }
        
    }
    
    @MainActor
    func getLocations(closure: @escaping () -> Void) {
        Task {
            doneLoading = false
            do {
                let docs = try await LocationManager.shared.getAllLocations()
                
                for locdoc in docs {
                    let lat = locdoc.get("lat") as? Double ?? 0.0
                    let lon = locdoc.get("lon") as? Double ?? 0.0
                    let address = locdoc.get("address") as? String ?? ""
                    let deadline = locdoc.get("deadline") as? Timestamp ?? Timestamp()
                    let addressURL = "maps://?saddr=&daddr=\(lat),\(lon)"
                    let isGoalMet = goalIsMet(doc: locdoc)
                    
                    locations.append(
                        Location(
                            doc: locdoc,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            address: address, 
                            addressURL: addressURL,
                            deadline: deadline.dateValue(),
                        isGoalMet: isGoalMet)
                    )
                }
            } catch {
                showAlert = true
                description = "Failed to load."
            }
            
            doneLoading = true
            closure()
        }
         
        doneLoading = true
   
    }
    
    @MainActor
    func deleteLocation(completion: @escaping (String?) -> Void) {
        Task {
            guard let loc = selectedLocation else {
                completion(nil)
                return
            }

            do {

                try await LocationManager.shared.deleteLocation(id: loc.doc.documentID)
                showTrackerView = false
                selectedLocation = nil
                completion(loc.address)
                locations = locations.filter {$0.doc.documentID != loc.doc.documentID }
            } catch {
                completion(nil)
                showAlert = true
                description = "Failed to delete tracker."
            } 
        }
        
        
    }
    

    
    func goalIsMet(doc: DocumentSnapshot)  -> Bool {
        
        
        let tempGoal = doc.get("goal") as? Int ?? 0
        
        //Getting the current item amounts
        var templocationItems = MockData.locationItems.map {
            var temp = $0
            temp.amount = doc.get($0.firebaseRef) as? Int ?? 0
            return temp
        }.sorted {($0.amount / $0.per_bag) < ($1.amount / $1.per_bag) }
        
        //Removing the invalid proteins.
        templocationItems.removeAll(where: {$0.amount == -1})
        
        //Check the data
        let currAmt = templocationItems.map { $0.amount / $0.per_bag }.min() ?? 0
        
        return currAmt >= tempGoal
    }
    
    @MainActor
    func getItems() async {
        guard let loc = selectedLocation else {
            return
        }
        do {
            let doc = try await LocationManager.shared.getLocation(id: loc.doc.documentID)
            locationId = doc.get("location_id") as! String
            goal = doc.get("goal") as? Int ?? 0
            
            //Getting the current item amounts
            locationItems = MockData.locationItems.map {
                var temp = $0
                temp.amount = doc.get($0.firebaseRef) as? Int ?? 0
                return temp
            }.sorted {($0.amount / $0.per_bag) < ($1.amount / $1.per_bag) }
            
            //Removing the invalid proteins.
            locationItems.removeAll(where: {$0.amount == -1})
            
            //Setting the needed data
            currentAmount = locationItems.map { $0.amount / $0.per_bag }.min() ?? 0
            urgentItems = locationItems.filter{ (Double($0.amount)/Double(goal * $0.per_bag)) < 0.5}.count
            
        } catch {
            showAlert = true
            description = "Failed to get items."
        }
        
        
    }
    
    func regionThatFitsTo(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for coordinate in coordinates {
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude)
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude)
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude)
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude)
            }

            var region: MKCoordinateRegion = MKCoordinateRegion()
            region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
            region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
            region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
            region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
            return region
    }
}
