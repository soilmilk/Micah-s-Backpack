//
//  EventViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/27/23.
//

import Foundation
import SwiftUI

class EventDetailViewModel: ObservableObject {
   
    
    @Published var alertItem: AlertItem?
    @Published var showAlert = false
    @Published var title: String = "Sign Up"
    @Published var color: Color = Color.mbpBlue3
    @Published var showSignUpDetailView = false
    @Published var showAddEventModal = false
    @Published var userList: [UserInfo] = []
    
    @MainActor
    func handleUserAction (event: DBEvent) async {
        if (color == Color.mbpBlue3){
            showSignUpDetailView = true
        } else if (color == Color.red){
            let userId = UserManager.shared.currentDBUser?.userId ?? ""
            do {
                try await EventManager.shared.signUpEvent(
                    userId: userId,
                    eventId: event.event_id,
                    numberOfPeople: nil)
                
                var oldDict = event.userIdDict
                oldDict[userId] = nil
                
                do {
                    userList = try await EventManager.shared.getAllPeopleFromEvent(eventPeopleDict: oldDict)
                    color = Color.blue
                    title = "Sign Up"
                } catch {
                    showError()
                }
            } catch {
                showError()
            }
        }
    }
    
    @MainActor
    func loadPeopleNames(userIdDict: [String: Int]) async {
        //Checking if user is signed up
        if let _ = userIdDict[UserManager.shared.currentDBUser?.userId ?? ""] {
            title = "Unsign Up"
            color = Color.red
        }
        
        do {
            self.userList = try await EventManager.shared.getAllPeopleFromEvent(eventPeopleDict: userIdDict)
        } catch {
            showError()
        }
    }
     
    func showError() {
        alertItem = AlertContext.defaultError
        showAlert = true
    }
    
}
