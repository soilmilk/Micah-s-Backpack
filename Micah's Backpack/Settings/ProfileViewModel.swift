//
//  ProfileViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/20/24.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var inputFirstName = ""
    @Published var inputLastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var showRegularAlert = false
    @Published var description: String = ""
    @Published var showUpdateAlert = false
    @Published var alert = typeOfAlert.none
    @Published var userInput = ""
    @Published var done = true
    @Published var showSaveButton = false
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet {
            if let selectedPhoto = selectedPhoto {
                loadImage(from: selectedPhoto)
            }
        }
    }
    @Published var imageurl: URL? = nil
    @Published var image: Image?
    
    private var imagePath = ""
    
    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    @MainActor
    func onStart() async {
        if let name = UserManager.shared.currentDBUser?.name {
            let fullNameArr = name.components(separatedBy: "|")
            inputFirstName = fullNameArr[0]
            inputLastName = fullNameArr.count > 1 ? fullNameArr[1] : ""
        }
        if let email = UserManager.shared.currentDBUser?.email {
            self.email = email
        }
        
        
        if let user = UserManager.shared.currentDBUser {
            do {
                imagePath = user.imagePath ?? "event_images/default.jpeg"
                imageurl = try await StorageManager.shared.getURLForPath(path: imagePath)
            } catch {
                showAlert(desc: "Failed to load profile picture.")
            }
        }
        
    }
    
    @MainActor
    func saveChanges() {
        showSaveButton = false
        if !inputFirstName.isEmpty && !inputLastName.isEmpty {
            done = false
            Task {
                do {
                    let newName = inputFirstName + "|" + inputLastName
                    try await UserManager.shared.changeUserName(newName: newName)
                    UserManager.shared.currentDBUser?.name = newName
                    
                    if let photo = selectedPhoto {
                        guard let data = try await photo.loadTransferable(type: Data.self) else {
                            showAlert(desc: "Failed to save photo.")
                            return
                        }
                        let (firebase_path, _) = try await StorageManager.shared.saveEventImage(data: data)
                        
                        
                        let oldImagePath = imagePath
                        
                        if oldImagePath != "event_images/default.jpeg" {
                            do {
                                try await StorageManager.shared.deleteImage(path: oldImagePath)
                            } catch {
                                //Do nothing
                            }
                        }
                        try await UserManager.shared.changeUserImagePath(imagePath: firebase_path)
                        imageurl  = try await StorageManager.shared.getURLForPath(path: firebase_path)
                        
                    }
                    done = true
                    showAlert(desc: "Saved Successfully!")
                } catch {
                    showAlert(desc: "\(error)")
                }
            }
        } else {
            showAlert(desc: "One or more fields is empty.")
        }
    }
    
    
    @MainActor
    func updatePasswordOrEmail() {
        if !userInput.isEmpty {
            Task {
                do {
                    if (alert == typeOfAlert.email) {
                        try await updateEmail(email: userInput)
                        showAlert(desc: "Email Updated!")
                    } else if (alert == typeOfAlert.password){
                        try await updatePassword(password: userInput)
                        showAlert(desc: "Password Updated!")
                    }
                } catch  {
                    showAlert(desc: error.localizedDescription)
                }
            }
        }
    }
    
    func showAlert(desc: String){
        description = desc
        showRegularAlert = true
    }

    func loadImage(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                guard let data = try await imageSelection.loadTransferable(type: Data.self) else {
                    self.image = nil
                    return
                }
                DispatchQueue.main.async {
                    if let uiImage = UIImage(data: data) {
                        self.image = Image(uiImage: uiImage)
                    }
                }
            } catch {
                self.image = nil
            }
        }
    }
}
