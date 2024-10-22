//
//  AuthenticationManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/31/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoURL: String?
    let displayName: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.displayName = user.displayName
    }
}


enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    //singleton
    static let shared = AuthenticationManager()
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private init() {}
    
    func getAllUserNames(userIds: [String]) async throws -> QuerySnapshot? {
        try await userCollection.whereField(DBUser.CodingKeys.userId.rawValue, in: userIds ).getDocuments() 
    }
    
    //No async here because this checks LOCALLY
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
    
    //google.com
    //password
    
    //One user could sign in with email or google, so providerData is an array []
    func getProviders() throws -> [AuthProviderOption]{
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found. \(provider.providerID)")
            }
        }
        
        return providers
    }
    
}

//MARK: SIGN IN EMAIL
extension AuthenticationManager {
    //Async - reaching out to the server
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
        
    }
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            //Custom Errors
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    
    }
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            //Custom Errors
            throw URLError(.badServerResponse)
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    
    }
}

//MARK: SIGN IN SSO
extension AuthenticationManager {
    //Better readibility; signing in "with google" is actually just signing in with a credential
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(
            withProviderID: AuthProviderOption.apple.rawValue,
            idToken: tokens.token,
            rawNonce: tokens.nonce
          )
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult =  try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

