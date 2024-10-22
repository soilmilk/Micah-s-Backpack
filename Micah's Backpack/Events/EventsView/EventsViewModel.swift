//
//  EventsViewModel.swift
//  OptimisingFirestore
//
//  Created by Anthony Du on 2/11/24.
//

import Firebase
import FirebaseFirestore

@MainActor
class EventsViewModel: ObservableObject {
    
    @Published var localDataCount = 0
    @Published var remoteDataCount = 0
    @Published var searchTerm = ""
    @Published var eventsSignedUp: [DBEvent] = []
    @Published var eventsUpcoming: [DBEvent] = []
    
    
    func getEvents() async {
        do {
            guard let result = try await EventManager.shared.getAllUpdatedEvents() else {
                return
            }

            var events: [DBEvent] = []
            var localEvents = (DBEvent.loadFromFile() ?? [])
            for document in result.documents {
                let documentData = document.data()
                
                //Check for any past events.
                //Check if document is already present. If so, delete the old one:
                localEvents.removeAll(where: {$0.event_id == documentData[DBEvent.CodingKeys.eventId.rawValue] as? String})

                if documentData[DBEvent.CodingKeys.is_deleted.rawValue] as? Bool == true {
                    // Remove deleted events from the local cache
                    localEvents.removeAll(where: {$0.event_id == documentData[DBEvent.CodingKeys.eventId.rawValue] as? String})
                } else {
                    events.append(DBEvent(
                        event_id: documentData[DBEvent.CodingKeys.eventId.rawValue] as? String ?? "",
                        image_path: documentData[DBEvent.CodingKeys.image_path.rawValue] as? String ?? "",
                        name: documentData[DBEvent.CodingKeys.name.rawValue] as? String ?? "",
                        description: documentData[DBEvent.CodingKeys.description.rawValue] as? String ?? "",
                        address: documentData[DBEvent.CodingKeys.address.rawValue] as? String ?? "",
                        cityStateZip: documentData[DBEvent.CodingKeys.cityStateZip.rawValue] as? String ?? "",
                        addressURL: documentData[DBEvent.CodingKeys.addressURL.rawValue] as? String ?? "",
                        userIdDict: documentData[DBEvent.CodingKeys.userIdDict.rawValue] as? [String: Int] ?? [:],
                        start_date: (documentData[DBEvent.CodingKeys.startDate.rawValue] as? Timestamp ?? Timestamp()).dateValue(),
                        end_date: (documentData[DBEvent.CodingKeys.endDate.rawValue] as? Timestamp ?? Timestamp()).dateValue(),
                        lastUpdated: (documentData[DBEvent.CodingKeys.lastUpdated.rawValue] as? Date ?? Date())))
                }
            }

            self.localDataCount = localEvents.count
            self.remoteDataCount = events.count
            

            localEvents = localEvents.filter({
                // Remove events for which updated data is available
                let event = $0
                return !events.contains(where: {$0.id == event.id})
            })
        

            events.append(contentsOf: localEvents)
            
            self.eventsSignedUp.removeAll()
            self.eventsUpcoming.removeAll()
            
            for event in events {
                if (event.end_date < Date()) {
                    //Past Event
                    if let index = events.firstIndex(of: event) {
                        events.remove(at: index)
                    }
                } else {
                    if (event.userIdDict[UserManager.shared.currentDBUser?.userId ?? ""] != nil) {
                        self.eventsSignedUp.append(event)
                    } else {
                        self.eventsUpcoming.append(event)
                    }
                }
                
            }
            
            self.eventsSignedUp = self.eventsSignedUp.sorted {$0.start_date < $1.start_date}
            self.eventsUpcoming = self.eventsUpcoming.sorted {$0.start_date < $1.start_date}

            DBEvent.saveToFile(events: events)
            UserDefaults.standard.set(Date(), forKey: "lastUpdatedDate")
            
        } catch {

        }
    }
}
