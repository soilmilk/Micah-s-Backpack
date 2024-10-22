//
//  ProfileViewModel.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/18/24.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    //Regular
    @Published var showRegularAlert = false
    @Published var description: String = ""
    //Update
    @Published var showUpdateAlert = false
    @Published var alert = typeOfAlert.none
    @Published var userInput = ""
    
    @Published var currentName: String? = nil
    
    @Published var notificationsOn: Bool = false
    
    //MARK: Firebase Functions
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
        UserManager.shared.currentDBUser = nil
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    func deleteAccount(userId: String) async throws {
        try await UserManager.shared.deleteUser(user_id: userId)
        UserManager.shared.currentDBUser = nil
        try await AuthenticationManager.shared.deleteUser()
        
    }
    
    //MARK: UI Functions
    
    func showAlert(desc: String){
        description = desc
        showRegularAlert = true
    }
    
    
   

    

     
}
