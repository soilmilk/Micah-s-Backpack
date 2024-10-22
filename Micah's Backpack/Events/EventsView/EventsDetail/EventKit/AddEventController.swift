//
//  AddEventController.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/16/24.
//

import UIKit
import EventKit
import EventKitUI

class AddEventController: UIViewController, EKEventEditViewDelegate {
    
    private let eventStore = EKEventStore()
    
   
    
    var dbEvent: DBEvent
    init(dbEvent: DBEvent) {
        self.dbEvent = dbEvent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var event: EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = dbEvent.name
        event.startDate = dbEvent.start_date
        event.endDate = dbEvent.end_date
        event.location = dbEvent.address
        event.notes = dbEvent.description
        return event
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: false, completion: nil)
        parent?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if #available(iOS 17.0, *) {
            let eventController = EKEventEditViewController()
            eventController.event = self.event
            eventController.eventStore = self.eventStore
            eventController.editViewDelegate = self
            
            self.present(eventController, animated: false, completion: nil)
        } else {
            // Fallback on earlier versions
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                DispatchQueue.main.async {
                    guard (granted) else {
                        return
                    }
                    if (granted) && (error == nil) {
                        let eventController = EKEventEditViewController()

                        eventController.event = self.event
                        eventController.eventStore = self.eventStore
                        eventController.editViewDelegate = self
                        eventController.modalPresentationStyle = .overCurrentContext
                        eventController.modalTransitionStyle = .crossDissolve
                        
                        self.present(eventController, animated: false, completion: nil)
                    }
                }
            })
        }
    }
}
