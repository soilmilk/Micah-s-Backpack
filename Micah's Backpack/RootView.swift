//
//  RootView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/31/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


class Model: ObservableObject {
    @Published var show: Bool = true
}

//MARK: ViewModel
@MainActor
final class RootViewModel: ObservableObject {
    //RootView
    @Published var showSignUpButtons: Bool = false
    
    //Sign In
    @Published var signInEmail = ""
    @Published var signInPassword = ""
    @Published var errorDescription = ""
    @Published var showAlert = false
    @Published var showUpdateAlert = false
    @Published var userInput = ""
    
    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()

    
    //Sign Up
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    
    //UI
    @Published var showView = false
    @Published var showHomeView = true
    @Published var isSignIn = true
    
    func reset() {
        signInEmail = ""
        signInPassword = ""
        signUpEmail = ""
        signUpPassword = ""
        showView = true
        showHomeView = true
        isSignIn = true
    }
    func setLocalDBUser() async {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser(),
              let dbUser = try? await UserManager.shared.getUser(userId: authUser.uid) else {
            showSignUpButtons = true
            return
        }
        UserManager.shared.currentDBUser = dbUser
        
    }
    
    func loadCurrentUser(closure: @escaping () -> Void) async {
        showSignUpButtons = false
        
        
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else {
            showSignUpButtons = true
            closure()
            return
        }
        
        if let dbUser = try? await
            UserManager.shared.getUser(userId: authUser.uid){
            UserManager.shared.currentDBUser = dbUser
        }
        closure()
    }
    
    //MARK: Sign In Functions
    
    
    func signIn() async throws {
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            throw CustomError.emptyFields
        }
        let authDataResult = try await AuthenticationManager.shared.signInUser(email: signInEmail, password: signInPassword)
        
        let user = DBUser(auth: authDataResult, name: nil, imagePath: nil)
        try await UserManager.shared.createNewUser(user: user)
        
        return
    }
    
    func signInGoogle() async throws  {
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        
        let user = DBUser(auth: authDataResult, name: nil, imagePath: nil)
        try await UserManager.shared.createNewUser(user: user)
        
        return
    }
    
    func signInApple() async throws  {
        self.didSignInWithApple = false
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                 Task {
                     do {
                         let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: signInAppleResult)
                         
                         let user = DBUser(auth: authDataResult, name: nil, imagePath: nil)
                         
                         try await UserManager.shared.createNewUser(user: user)
                         
                         self.didSignInWithApple = true
                         
                         
                     } catch {
                         self.showAlert = true
                         self.errorDescription = "Failed to sign in with Apple."
                         
                     }
                
                 }

            case .failure( _):
                self.showAlert = true
                self.errorDescription = "Failed to sign in with Apple."
            }
        }
        
        
           
    }
    

        
    
    @MainActor
    func sendPasswordReset() {
        Task {
            do {
                try await AuthenticationManager.shared.resetPassword(email: userInput)
                errorDescription = "Check your email for a new password reset!"
                showAlert = true
            } catch {
                errorDescription = error.localizedDescription
                showAlert = true
            }
        }
        
    }
    
    
    //MARK: Sign Up Functions
    
    
    func signUp() async throws -> Bool {
        guard !signUpEmail.isEmpty, !signUpPassword.isEmpty else {
            errorDescription = "One or more fields is empty."
            showAlert = true
            return false
        }
        let authDataResult = try await AuthenticationManager.shared.createUser(email: signUpEmail, password: signUpPassword)
        let user = DBUser(auth: authDataResult, name: nil, imagePath: nil)
        try await UserManager.shared.createNewUser(user: user)
        
        return true
        
    }
    
    
}




//MARK: View
struct RootView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewmodel = RootViewModel()
    
    let layoutProperties: LayoutProperties
    
    @StateObject var model = Model()
    
    @State var scale: CGFloat = 0
    
    
    var body: some View {
        NavigationStack {
            if model.show {
                ZStack {
                    Color.mbpBlue4.ignoresSafeArea()
                
                    CirclesView(width: layoutProperties.width, scale: scale)
                     
                    
                    if viewmodel.showView {
                        VStack {
                            if viewmodel.showHomeView {
                                AdaptiveImage(light: Image("logo"), dark: Image("logo_dark"))

                                signInWithEmailButton
                                
                                createAccountButton

                                appleAndGoogleButtons
                                  
                            } else {
                                if viewmodel.isSignIn{
                                    signInView
                                } else {
                                    signUpView
                                }
                            }
                            Spinner(size: 50)
                                .opacity(viewmodel.showSignUpButtons ? 0: 1)
                        }
                        .transition(.scale)
                        .padding()
                    }
                    Spacer()
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .frame(width: layoutProperties.width, height: layoutProperties.height)
                
            } else {
                ContentView(showSignInView: $model.show)
                    .task {
                        DBEvent.resetPlistFile()
                        if UserManager.shared.currentDBUser == nil {
                            await viewmodel.setLocalDBUser()
                        }
                    }
                    .environmentObject(model)
            }
            
        }
        .onAppear {
            model.show = true
            viewmodel.didSignInWithApple = false
            withAnimation(.bouncy.speed(1).delay(0.5)) {
                scale = 1.8
                viewmodel.showView = true
            }
            Task {
                await viewmodel.loadCurrentUser {
                    DispatchQueue.main.async {
                        withAnimation (.default) {
                            model.show = viewmodel.showSignUpButtons
                        }
                    }
                    
                }
            }
        }
        .alert("Alert!", isPresented: $viewmodel.showAlert) {
            Button("OK"){}
        } message: {
            Text(viewmodel.errorDescription)
        }
        .alert("Alright!", isPresented: $viewmodel.showUpdateAlert) {
            TextField("Email...", text: $viewmodel.userInput)
            Button {
                viewmodel.sendPasswordReset()
            } label: {
                Text("OK")
            }
        } message: {
            Text("Enter the email associated with this password:")
        }
  
    }
    
    //MARK: Variables
    
    
    var signInView: some View {
        VStack {
            
            BackButton(showHomeView: $viewmodel.showHomeView)
            
            TextField("Email . . . ", text: $viewmodel.signInEmail)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            
            SecureField("Password . . . ", text: $viewmodel.signInPassword)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            
            Button {
                Task {
                    do {
                        try await viewmodel.signIn()
                        model.show = false
                        viewmodel.reset()
                        return
                    } catch (CustomError.emptyFields){
                        viewmodel.errorDescription = "No email or password found."
                        viewmodel.showAlert = true
                    } catch {
                        viewmodel.errorDescription = error.localizedDescription
                        viewmodel.showAlert = true
                    }
                    
                }
                
                
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: layoutProperties.height/12)
                    .frame(maxWidth: .infinity)
                    .background(Color.mbpBlue3)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            
            Button {
                viewmodel.showUpdateAlert = true
            } label: {
                Text("Forgot Password?")
                    .font(.callout)
                    .foregroundStyle(.mbpBlue2)
            }
            
            
        }
    }
    
    var signUpView: some View {
        VStack {
            
            BackButton(showHomeView: $viewmodel.showHomeView)
            
            TextField("Email . . . ", text: $viewmodel.signUpEmail)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            
            SecureField("Password . . . ", text: $viewmodel.signUpPassword)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            Button {
                Task {
                    do {
                        if try await viewmodel.signUp() {
                            model.show = false
                            viewmodel.reset()
                        }
                        return
                    } catch {
                        viewmodel.errorDescription = "The email address is invalid."
                        viewmodel.showAlert = true
                    }
                    
                }
                
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: layoutProperties.height/12)
                    .frame(maxWidth: .infinity)
                    .background(Color.mbpBlue3)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.vertical)
            
        }
    }
    
    @ViewBuilder func CustomButton(isGoogle: Bool = false) -> some View {
        HStack {
            Group {
                if isGoogle {
                    Image("googlelogo")
                        .resizable()
                        .renderingMode(.template)
                    
                } else {
                    Image(systemName: "applelogo")
                        .resizable()
                    
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign In")
                .font(.system(size: 15))
                .lineLimit(1)
        }
        .foregroundStyle(.mbpWhite2)
        .padding(.horizontal, 15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.mbpBlack)
        }
    }
    
    var signInWithEmailButton: some View {
        Button {
            withAnimation(.spring(duration: 1)) {
                viewmodel.showHomeView = false
                viewmodel.isSignIn = true
            }
        } label: {
            PrimaryButton(title: .constant("Sign In With Email"), color: .constant(Color.mbpBlue3))
                .frame(height: layoutProperties.height/12)
            
        }
        .opacity(viewmodel.showSignUpButtons ? 1: 0)
    }
    
    var createAccountButton: some View {
        Button {
            withAnimation(.spring(duration: 1)) {
                viewmodel.showHomeView = false
                viewmodel.isSignIn = false
            }
        } label: {
            PrimaryButton(title: .constant("Create an Account"), color: .constant(Color.mbpBlue3))
                .frame(height: layoutProperties.height/12)
            
        }
        .opacity(viewmodel.showSignUpButtons ? 1: 0)
    }
    
    var appleAndGoogleButtons: some View {
        HStack {
            Button {
                Task {
                    do {
                        try await viewmodel.signInApple()
                    } catch {
                        viewmodel.errorDescription = error.localizedDescription
                        viewmodel.showAlert = true
                    }
                }
                
            } label: {
                CustomButton()
                    .clipped()
            }
            .onChange(of: viewmodel.didSignInWithApple) {newValue in
                if newValue {
                    model.show = false
                    viewmodel.reset()
                }
            }

            Button {
                Task {
                    do {
                        try await viewmodel.signInGoogle()
                        model.show = false
                        viewmodel.reset()
                        
                    } catch {
                        viewmodel.errorDescription = error.localizedDescription
                        viewmodel.showAlert = true
                    }
                }
            } label: {
                CustomButton(isGoogle: true)
                    .clipped()
            }
            
        }
        .padding(.top)
        .opacity(viewmodel.showSignUpButtons ? 1: 0)
    }
    
}

#Preview {
    RootView(layoutProperties: getPreviewLayoutProperties(height: 667, width: 375))
}

//MARK: Structs
struct CirclesView: View {
    @Environment(\.colorScheme) var colorScheme
    let width: CGFloat
    let scale: CGFloat
    var body: some View {
        Circle()
            .scale((scale*1.15)/393*width*0.9)
            .foregroundStyle(.mbpWhite.opacity(colorScheme == .light ? 0.18: 0.55))
        
        Circle()
            .scale(scale/393*width*0.9)
            .foregroundStyle(.mbpWhite)
    }
}


struct AdaptiveImage: View {
    @Environment(\.colorScheme) var colorScheme
    let light: Image
    let dark: Image
    
    @ViewBuilder var body: some View {
        if colorScheme == .light {
            light
                .resizable()
                .scaledToFit()
                .padding(.bottom)
                .transition(.opacity)
        } else {
            dark
                .resizable()
                .scaledToFit()
                .padding(.bottom)
                .transition(.opacity)
        }
        
    }
}

struct BackButton: View {
    
    @Binding var showHomeView: Bool
    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 1)) {
                    showHomeView = true
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .foregroundStyle(.mbpBlue2)
                    Spacer()
                }
                .frame(width: 30, height: 30)
                
            }
            Spacer()
        }
        .padding()
    }
}



