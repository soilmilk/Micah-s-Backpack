//
//  SignUpDetailView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/27/23.
//

import SwiftUI

struct SignUpDetailView: View {
    
    let event: DBEvent
    @Binding var userList: [UserInfo]
    @Binding var showSignUpDetailView: Bool
    @Binding var color: Color
    @Binding var title: String
    @StateObject private var viewmodel =  SignUpDetailViewModel()
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            ZStack (alignment:.bottom) {
                Form {
                    Section(header: Text("")) {
                        EmptyView()
                            .frame(height: 50)
                    }
                    Section {
                        Picker("Number of People", selection: $viewmodel.userInputNumber)  {
                            ForEach(1..<26){
                                Text("\($0)")
                            }
                        }
                    } header: {
                        Text("Info")
                    }
                    
                }
                
                Button {
                    Task {
                        guard let result = await viewmodel.saveChanges(event: event) else {
                            return
                        }
                        userList = result
                        showSignUpDetailView = false
                        color = Color.red
                        title = "Unsign Up"
                    }
                } label: {
                    PrimaryButton(title: .constant("Save"), color: .constant(Color.blue))
                        .padding()
                }
            }
            Button {
                showSignUpDetailView = false
            } label: {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Cancel")
                        .font(.system(size: 18))
                }
                .padding()
            }
        }
        .alert("Oops!",
               isPresented: $viewmodel.showAlert,
               presenting: viewmodel.alertItem
        ) { alert in
            Button("OK") {}
        } message: { alert in
            Text(alert.message)
        }
    }
}
#Preview {
    SignUpDetailView(event: MockData.sampleDBEvent, userList: .constant([]), showSignUpDetailView: .constant(true), color: .constant(Color.red), title: .constant("test title"))
}


