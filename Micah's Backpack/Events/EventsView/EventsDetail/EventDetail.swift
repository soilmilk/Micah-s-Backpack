//
//  EventDetail.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/24/23.
//

import SwiftUI


struct EventDetail: View {
    
    
    @State var event: DBEvent
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = EventDetailViewModel()
    
    @State var show = false
    
    var body: some View {
        NavigationStack{
            ScrollView {
                HStack {
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
                    Spacer()
                    
                    if let result = UserManager.shared.currentDBUser?.isAdmin {
                        if result {
                            NavigationLink{
                                EventCreator(event: $event, isNewEvent: false)
                            } label: {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .bold()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.mbpBlue2)
                                
                            }
                            .foregroundStyle(.mbpBlue2)
                            .padding(.horizontal)
                            
                            
                            Button{
                                Task {
                                    do {
                                        let imagePath = event.image_path
                                        try await StorageManager.shared.deleteImage(path: imagePath)
                                    } catch {
                                        //If no image is available, delete the event
                                    }
                                    //Cannot directly delete from firebase due to the reliance of cache on is_deleted
                                    do {
                                        try await EventManager.shared.replaceEventDeletedStatus(eventId: event.event_id)
                                        dismiss()
                                    } catch {
                                        viewModel.alertItem = AlertContext.errorInDelete
                                        viewModel.showAlert = true
                                    }
                                }
                                
                            } label: {
                                Image(systemName: "trash.fill")
                                    .resizable()
                                    .bold()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.red)
                            }
                            
                        }
                    }

                    
                }
                .padding()

                    
                    EventImage(imagePath: event.image_path)
                    if show {
                        TitleAndDateView(
                            viewmodel: viewModel, event: $event, eventName: event.name,
                            startEventDate: event.start_date.formatted(.dateTime.day().month()),
                            endEventDate: event.end_date.formatted(.dateTime.day().month()),
                            startEventTime: event.start_date.formatted(date: .omitted, time: .shortened),
                            endEventTime: event.end_date.formatted(date: .omitted, time: .shortened))
                        .transition(.opacity)
                        
                        HStack {
                            DetailView(eventDetail: event.description)
                            Spacer()
                        }
                        .padding(.horizontal, 27.5)
                        .padding(.vertical, 10)
                        .transition(.opacity)
                        
                        
                        Divider()
                        
                        PeopleSignedUpView(userList: viewModel.userList)
                        Divider()
                        
                        Button {
                            Task {
                                await viewModel.handleUserAction(event: event)
                            }
                        } label: {
                            PrimaryButton(title: $viewModel.title, color: $viewModel.color)
                                .padding(.horizontal)
                        }
                        
                    }
                
            }
            .toolbar(.hidden)
            .background(Color.primaryBg)
            .scrollIndicators(.hidden)
            .alert("Oops!",
                   isPresented: $viewModel.showAlert,
                   presenting:  viewModel.alertItem
            ) { alert in
                Button("OK") {}
            } message: { alert in
                Text(alert.message)
            }
            .sheet(isPresented: $viewModel.showSignUpDetailView, content: {
                SignUpDetailView(event: event, userList: $viewModel.userList,  showSignUpDetailView: $viewModel.showSignUpDetailView, color: $viewModel.color, title: $viewModel.title)
            })
            .sheet(isPresented: $viewModel.showAddEventModal) {
                AddEventView(dbEvent: event)
            }
            .task {
                await viewModel.loadPeopleNames(userIdDict: event.userIdDict)
                withAnimation (Animation.easeInOut(duration: 1.25).delay(0.5)) {
                    self.show = true
                }
            }
        }
        
        
        
        
    }
}



struct CustomDisclosureGroupStyle<Label: View>: DisclosureGroupStyle {
    let button: Label
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            button
                .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        }
        if configuration.isExpanded {
            configuration.content
                .disclosureGroupStyle(self)
        }
    }
}

struct RowView: View {
    
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
            Text(text)
                .font(.callout)
                .fontWeight(.medium)
            Spacer()
        }
    }
}

struct TitleAndDateView: View {
    
    @ObservedObject var viewmodel: EventDetailViewModel
    @Environment(\.openURL) private var openURL
    @Binding var event: DBEvent
    let eventName: String
    let startEventDate: String
    let endEventDate: String
    let startEventTime: String
    let endEventTime: String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                HStack {
                    Text(eventName)
                        .font(.system(size: 40))
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                    Spacer()
                }
                .frame(width: 225)
  
                Spacer()
                VStack{
                    HStack(spacing: 10) {
                        Button {
                            openURL(URL(string: event.addressURL)!) { canOpen in
                                if (!canOpen){
                                    viewmodel.alertItem = AlertContext.invalidMapURL
                                    viewmodel.showAlert = true
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Directions")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(.white)
                            .frame(width: 120, height: 45)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                        }
                    }
                    
                    Button {
                        viewmodel.showAddEventModal.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Add")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 45)
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                }
                
            }
            HStack {
                Text(startEventDate == endEventDate ? startEventDate: startEventDate + "-" + endEventDate)
                Text("•")
                Text(startEventTime == endEventTime ? startEventTime : startEventTime + "-" + endEventTime)
                    
            }
            .fontWeight(.medium)
            .font(.title3)
            .foregroundStyle(.secondary)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
}

struct DetailView: View {
    
    let eventDetail: String
    var body: some View {
        VStack (alignment: .leading){
            Text("Description")
                .fontWeight(.medium)
                .font(.title3)
            Text(eventDetail)
                .font(.body)
                .fontWeight(.regular)
                .foregroundStyle(.secondary)
        }
    }
}



#Preview {
    EventDetail(event: MockData.sampleDBEvent)
}


struct EventImage: View {
    
    let imagePath: String
    var body: some View {
        CachedImage(imgPath: imagePath, animation: .spring(), transition: .push(from: .top).combined(with: .opacity)) {phase in
            switch phase {
            case .empty:
                Spinner(size: 50)
                    .frame(width: 400, height: 400)
            case .success(let image):
                image
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .frame(width: 350, height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .clipped()
            case .failure(_):
                Image("backpack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            @unknown default:
                EmptyView()
            }
            
        }
    }
}

struct PeopleSignedUpView: View {
    
    let userList: [UserInfo]
    
    var body: some View {
        VStack(spacing: 5) {
            DisclosureGroup(
                content: {
                    ForEach(userList) { user in
                        VStack(alignment: .leading) {
                            HStack {
                                UserImageView(imagePath: user.imagePath)
                                
                                Text(user.userName)
                                Spacer()
                                Text(String(user.numOfGuests))
                                    .foregroundStyle(Color(.mbpBlue2))
                                    .padding()
                                    .background(
                                        Circle()
                                            .stroke(.blue, lineWidth: 2)
                                            .padding(10)
                                    )
                                    
                                
                            }
                            Divider()
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.top, 5)
                },
                label: {
                    RowView(text: "People Attending", icon: "person")
                        .padding(.leading, 5)
                }
            )
            .tint(.blue)
            .disclosureGroupStyle(CustomDisclosureGroupStyle(button: Label("", systemImage: "chevron.right")))
        }
        .padding(10)
    }
}


struct UserImageView: View {
    let imagePath: String
    var body: some View {
        CachedImage(imgPath: imagePath, animation: .spring(), transition: .scale.combined(with: .opacity)) {phase in
            switch phase {
            case .empty:
                Spinner(size: 20)
                    .frame(width: 50, height: 50)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.gray)
                            .frame(width: 50, height:  50)
                    }
            case .failure(_):
                Image("backpack")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            @unknown default:
                EmptyView()
            }
            
        }
    }
}
