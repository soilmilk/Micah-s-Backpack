//
//  Alert.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/12/24.
//

import Foundation
//
//  Alert.swift
//  Appetizers
//
//  Created by Anthony Du on 12/20/23.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    let message: String

}

struct AlertContext {
    
    static let defaultError = AlertItem(message: "Something went wrong.")
    static let invalidMapURL = AlertItem(message: "The requested location is invalid. Please email hope@micahsbackpack.org for help.")
    static let emptyFields = AlertItem(message: "No email or password found.")
    
    static let emptyEventFields = AlertItem(message: "Please fill out all the fields!")
    static let emptyName = AlertItem(message: "Please go to your Profile to set your name.")
     
    static let userNotFound = AlertItem(message: "The email and password does not match a registered user.")
    
    static let noImageSelected = AlertItem(message: "Please upload an image for the event.")
    static let errorInChangeName = AlertItem(message: "Please check your network or log out/in and try again.")
    
    //MARK: Firebase
    static let errorInDelete = AlertItem(message: "Failed to delete event.")
    static let errorInCreateOrUpdate = AlertItem(message: "Failed to create or update the event.")
    
    static let errorInRetrieveEvents = AlertItem(message: "Please check your network in order to see the events.")
    static let errorInFields = AlertItem(message: "The email address is invalid.")
    static let passwordError = AlertItem(message: "The password must be 6 characters long or more")
     
    
}
