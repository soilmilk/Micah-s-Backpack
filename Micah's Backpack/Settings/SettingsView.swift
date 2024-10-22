//
//  SetingsView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/3/24.
//

import SwiftUI


struct SettingsView: View {
    
    @Environment(\.openURL) var openURL
    @Environment (\.dismiss) var dismiss
    @Binding var showSignInView: Bool
    @StateObject private var viewmodel = SettingsViewModel()
    @EnvironmentObject var model: Model
 
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    backButton
                    Spacer()
                    signOutButton
                }
                .padding()
                
                NavigationLink{
                    ProfileView()
                } label: {
                    HStack (alignment: .center){
                        UserImageSmall(imagePath: "\(UserManager.shared.currentDBUser?.imagePath ?? "event_images/default.jpeg")")
                            .padding(.leading, 10)
                            .padding(.trailing, 5)
                        
                        VStack (alignment: .leading, spacing: 6){
                            Text(viewmodel.currentName?.replacingOccurrences(of: "|", with: " ") ?? "Volunteer")
                                .font(.title2)
                                .foregroundStyle(Color.mbpBlack)
                            Text("\(UserManager.shared.currentDBUser?.email ?? "No Email")")
                                .font(.title3)
                                .padding(.leading, 3)
                                .foregroundStyle(Color.mbpBlack)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFill()
                            .frame(width:10, height: 10)
                            .foregroundStyle(Color.mbpBlack)
                            .padding()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.mbpWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
                .padding(.bottom)
                VStack {
                    let toggle = Binding<Bool> (
                        get: { viewmodel.notificationsOn},
                        set: { _ in
                            if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(appSettings as URL)
                            }
                        })
                    
                    Toggle("Notifications", isOn: toggle)
                        .font(.title3)
                        .padding(.bottom)
                    
                    
                    
                    
                    NavigationLink {
                        AboutUsView()
                    } label: {
                        HStack {
                            Text("About us")
                                .font(.title3)
                                .foregroundStyle(.mbpBlack)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(.mbpBlack)
                        }
                        .padding(.vertical)
                    }
                
                    
                    HStack {
                        Button {
                            openURL(URL(string: "https://sites.google.com/view/micahs-bp/terms-of-service")!)
                        } label: {
                            Text("Terms of Service")
                                .font(.title3)
                                
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFill()
                                .frame(width:10, height: 10)
                            
                        }
                        .foregroundStyle(.mbpBlack)
                        
                        
                    }
                    .padding(.vertical)
                    HStack {
                        Button {
                            openURL(URL(string: "https://sites.google.com/view/micahs-bp/privacy-policy")!)
                        } label: {
                            Text("Privacy Policy")
                                .font(.title3)
                                
                            Spacer()
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFill()
                                .frame(width:10, height: 10)
                            
                        }
                        .foregroundStyle(.mbpBlack)
                        
                        
                    }
                    .padding(.vertical)
                    

                    
                    
                    HStack {
                        deleteAccountButton
                        Spacer()
                    }
                    .padding(.top)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mbpWhite)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                
                VStack {
                    HStack {
                        ShareLink(item: URL(string: "http://micahsbackpack.org/mobile-app/")!, subject: Text("Download App Here"), message: Text("Check out our mobile app to stay updated!")) {
                            Label("Share this App", systemImage: "square.and.arrow.up")
                                .font(.title3)
                        }
                        Spacer()
                        
                    }
                    HStack {
                        Button {
                            if (!sendEmail()){
                                viewmodel.showAlert(desc: "This device does not support direct links. Please email hope@micahsbackpack.org for any questions.")
                            }
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.title3)
                            Text("Get Support")
                                .font(.title3)
                        }
                        Spacer()
                    }
                    .padding(.top)

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mbpWhite)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                
            }
            .toolbar(.hidden)
            .alert("Alert!", isPresented: $viewmodel.showRegularAlert) {
                Button("OK"){}
            } message: {
                Text(viewmodel.description)
                    .font(.title3)
            }
            .onAppear {
                viewmodel.currentName = UserManager.shared.currentDBUser?.name
                viewmodel.loadAuthProviders()
                
                
                
                Task {
                    await NotificationManager.shared.getAuthStatus()
                    
                    viewmodel.notificationsOn = NotificationManager.shared.hasPermission
                    
                }
                    
            }
            .background(.primaryBg)
        }
    }
    
    var signOutButton: some View {
        Button {
            Task {
                do {
                    try viewmodel.signOut()
                    model.show = true
                    dismiss()
                } catch {
                    viewmodel.showAlert(desc: error.localizedDescription)
                }
            }
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .resizable()
                .bold()
                .frame(width: 30, height: 30)
                .foregroundStyle(.mbpBlue2)
        }
    }
    var deleteAccountButton: some View {
        Button(role: .destructive) {
            Task {
                do {
                    guard let id =  UserManager.shared.currentDBUser?.userId else {
                        return
                    }
                    try await viewmodel.deleteAccount(userId: id)
                    model.show = true
                    dismiss()
                    return
                } catch {
                    viewmodel.showAlert(desc: error.localizedDescription)
                }
            }
        } label: {
            Text("Delete Account")
                .font(.title3)
        }
    }
   var backButton: some View {
        Button{
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundStyle(.mbpBlue2)
            Text("Back")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.mbpBlue2)
        }
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}



enum typeOfAlert {
    case password
    case email
    case none
    
    var description : String {
        switch self {
        case .password: return "password"
        case .email: return "email"
        case .none: return ""
        }
    }
}



struct UserImageSmall: View {
    let imagePath: String
    var body: some View {
        CachedImage(imgPath: imagePath, animation: .spring(), transition: .scale.combined(with: .opacity)) {phase in
            switch phase {
            case .empty:
                Spinner(size: 20)
                    .frame(width: 70, height: 70)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            case .failure(_):
                Image("backpack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
            @unknown default:
                EmptyView()
            }
            
        }
    }
}



func sendEmail() -> Bool{
    let email = "hope@micahsbackpack.org"
    let subject = ""
    let body = ""
    
    let emailURL = "mailto:\(email)?subject=\(subject)&body=\(body)"
 
    guard let encodedURL = emailURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedURL) else {
            return false
    }
    
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
    return false
}
