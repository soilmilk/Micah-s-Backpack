//
//  AddEventView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/16/24.
//

import SwiftUI
import EventKitUI

struct AddEventView: UIViewControllerRepresentable {
    
    private let eventStore = EKEventStore()
    let dbEvent: DBEvent
    
    private var event: EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = dbEvent.name
        event.startDate = dbEvent.start_date
        event.endDate = dbEvent.end_date
        event.location = dbEvent.address
        event.notes = dbEvent.description
        return event
    }

    func makeUIViewController(context: Context) -> AddEventController {
        return AddEventController(dbEvent: dbEvent)
    }
    /*
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        if #available(iOS 17.0, *) {
            let eventEditViewController = EKEventEditViewController()
                eventEditViewController.event = event
                eventEditViewController.eventStore = eventStore
                eventEditViewController.editViewDelegate = context.coordinator
                return eventEditViewController
        } else {
            //Fallback to older versions
        }
    }
     */
            
    
    func updateUIViewController(_ uiViewController: AddEventController, context: Context) {
    }
    
    /*
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        <#code#>
    }
     
    
    func makeCoordinator() -> Coordinator {
           return Coordinator(self)
        }
       
        class Coordinator: NSObject, EKEventEditViewDelegate {
            var parent: AddEventView
           
            init(_ controller: AddEventView) {
                self.parent = controller
            }
           
            func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
     */
}

#Preview {
    AddEventView(dbEvent: MockData.sampleDBEvent)
}
