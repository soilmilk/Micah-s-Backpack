//
//  EventViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/27/23.
//

import Foundation

class SignUpDetailViewModel: ObservableObject {
    //@Published var user = User()

    
    @Published var showAlert = false
    @Published var alertItem: AlertItem?
    @Published var comment: String = ""
    @Published var userInputName = ""
    @Published var userInputNumber = 0
    
    func initializeEvents () {
        //
    }
    
    @MainActor
    func saveChanges(event: DBEvent) async -> [UserInfo]? {
        if (UserManager.shared.currentDBUser?.name) != nil {
            do {
                
                let userId = UserManager.shared.currentDBUser?.userId ?? ""
                try await EventManager.shared.signUpEvent(
                    userId: userId,
                    eventId: event.event_id,
                    numberOfPeople: userInputNumber + 1)

                var oldDict = event.userIdDict
                oldDict[userId] = userInputNumber + 1
                
                do {
                    return try await EventManager.shared.getAllPeopleFromEvent(eventPeopleDict: oldDict)
                    
                } catch {
                    showDefaultAlert()
                }
                
            } catch {
                showDefaultAlert()
            }
        } else {
            alertItem = AlertContext.emptyName
            showAlert = true
        }
        
        return nil
        
    }
    
    
    func showDefaultAlert(){
        alertItem = AlertContext.defaultError
        showAlert = true
    }
    
    
}
