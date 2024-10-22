//
//  ProfileView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/19/24.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var viewmodel = ProfileViewModel()
    var body: some View {
        ZStack(alignment: .center) {
            Color.primaryBg.ignoresSafeArea()
            VStack {
                PhotosPicker(selection: $viewmodel.selectedPhoto, matching: .images, photoLibrary: .shared()) {
                    ZStack (alignment: .center){
                        if let url = viewmodel.imageurl {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .modifier(UserImage())
                            } placeholder: {
                                Spinner(size: 30)
                                    .frame(width: 150, height:  150)
                            }

                        }
                        
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.gray)
                            .frame(width: 150, height: 150)
                        
                        
                        if let image = viewmodel.image {
                            image
                                .resizable()
                                .modifier(UserImage())
                        }
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background {
                                Circle()
                                    .fill(.gray)
                            }
                            .padding(.top, 90)
                            .padding(.leading, 120)     
                    }
                    
                }
                //Deprecated
                .onChange(of: viewmodel.selectedPhoto) { _ in
                    viewmodel.showSaveButton = true
                }
                
                HStack (spacing: 15) {
                    NameView(text: "First Name", inputPart: $viewmodel.inputFirstName, showSaveButton: $viewmodel.showSaveButton)
                    NameView(text: "Last Name", inputPart: $viewmodel.inputLastName, showSaveButton: $viewmodel.showSaveButton)
                }
                .padding()
                
                FieldView(isEmail: true, viewmodel: viewmodel)
                FieldView(isEmail: false, viewmodel: viewmodel)
                
                Spacer()
                
            }
            .task {
                await viewmodel.onStart()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewmodel.saveChanges()
                    } label: {
                        Text("Save")
                        
                    }
                    .opacity(viewmodel.showSaveButton ? 1: 0)
                }
            }
            .alert("Alert!", isPresented: $viewmodel.showRegularAlert) {
                Button("OK"){}
            } message: {
                Text(viewmodel.description)
            }
            .alert("Alright!", isPresented: $viewmodel.showUpdateAlert) {
                TextField("New \(viewmodel.alert.description)", text: $viewmodel.userInput)
                Button("OK") {
                    viewmodel.updatePasswordOrEmail()
                }
            } message: {
                Text("Type your new \(viewmodel.alert.description) below:")
            }
            
            Spinner(size: 50)
                .opacity(viewmodel.done ? 0: 1)
        }
        
    }
}

#Preview {
    ProfileView()
}

struct NameView: View {
    var text: String
    @Binding var inputPart: String
    @Binding var showSaveButton: Bool
    
    @State private var isEdited = false
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(text)
                .font(.headline)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.leading, 10)
            TextField("", text: $inputPart)
                .frame(height: 50)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onChange(of: inputPart) { _ in
                    if (isEdited) {showSaveButton = true}
                    isEdited = true
                }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isEdited = false
            showSaveButton = false
        }
    }
}

struct FieldView: View {
    
    let isEmail: Bool
    @ObservedObject var viewmodel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(isEmail ? "Email" : "Password")
                .font(.headline)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.leading, 10)
            ZStack (alignment: .leading){
                HStack {
                    Text(isEmail ? viewmodel.email : String(repeating: "•", count: 7))
                        .padding()
                    Spacer()
                    Button {
                        viewmodel.alert = isEmail ? typeOfAlert.email : typeOfAlert.password
                        viewmodel.showUpdateAlert = true
                    } label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundStyle(.black)
                    }
                    
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .frame(height: 50)
        }
        .padding()
    }
}

struct UserImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            //.resizable()
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 150, height:  150)
    }
}
