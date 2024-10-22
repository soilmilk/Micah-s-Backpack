//
//
//
//
//  Created by Anthony Du on 12/19/23.
//

import SwiftUI


struct EventsView: View {
    
    @State private var emptyDBEvent = DBEvent(event_id: "", image_path: "", name: "", description: "", address: "", cityStateZip: "", addressURL: "", userIdDict: [:], start_date: Date(), end_date: Date(),
                                              lastUpdated: Date())
    @StateObject private var viewmodel = EventsViewModel()
    @Binding var showSignInView: Bool
    @State var show = false
    
    let lp: LayoutProperties
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                if (show) {
                    if viewmodel.eventsSignedUp.count == 0 {
                        signUpForEventsView
                        
                    } else {
                        signedUpEvents(eventsSignedUp: viewmodel.eventsSignedUp, height: lp.height/3, width: lp.width * 0.7)
                    }
                    
                    HStack {
                        Text("Upcoming")
                            .foregroundStyle(.foreground.opacity(0.8))
                            .bold()
                            .font(.system(size: 20))
                        Spacer()
                        
                        if let result = UserManager.shared.currentDBUser?.isAdmin {
                            if result {
                                NavigationLink {
                                    EventCreator(event: $emptyDBEvent, isNewEvent: true)
                                } label: {
                                    Image(systemName: "calendar.badge.plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: lp.width/10)
                                }
                            }
                            
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                    .transition(.opacity.animation(.easeInOut.delay(1)))
                    
                    
                    SearchBar(text: $viewmodel.searchTerm)
                        .padding(.bottom)
                        .padding(.horizontal)
                        .transition(.opacity.animation(.easeInOut.delay(1.5)))
                    
                    LazyVStack {
                        ScrollView (.vertical, showsIndicators: false) {
                            VStack (spacing: 20) {
                                ForEach(viewmodel.eventsUpcoming.filter({$0.name.localizedStandardContains(viewmodel.searchTerm.capitalized) || viewmodel.searchTerm.isEmpty})) { event in
                                    NavigationLink{
                                        EventDetail(event: event)
                                    } label: {
                                        EventsCell2(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            
                        }
                    }
                    .transition(.push(from: .bottom).animation(.easeInOut.delay(3)))
                    .animation(.spring, value: viewmodel.searchTerm)
                    .padding(.bottom, 60)
                }
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.keyboard)
            .scrollContentBackground(.hidden)
            .background(Color.primaryBg)
            .task {
                await viewmodel.getEvents()
            }
            .onAppear {
                withAnimation (.easeInOut(duration: 0.5)) {
                    show = true
                }
            }
        }
    }
    

    
    var signUpForEventsView: some View {
        ZStack(alignment: .trailing) {
            HStack {
                VStack (alignment: .listRowSeparatorLeading){
                    Text("Sign up for events \ntoday")
                        .multilineTextAlignment(.leading)
                        .bold()
                        .font(.system(size: 25))
                        .foregroundStyle(.foreground)
                    Text("Help us out in achieving our goal ❤️")
                        .foregroundStyle(.secondary)
                    
                }
                Image("empty_events")
                    .resizable()
                    .frame(width: lp.scale(150), height: lp.scale(150))
                    .offset(x: 50)
            }
            .padding()
            .frame(maxWidth: .infinity)
            
        }
        .transition(.push(from: .trailing).combined(with: .opacity).animation(.easeInOut))
    }
}
    



#Preview {
    EventsView(showSignInView: .constant(false), lp: getPreviewLayoutProperties(height: 667, width: 375))
}

struct signedUpEvents: View {
    let eventsSignedUp: [DBEvent]
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                Text("Signed Up")
                    .bold()
                    .font(.system(size: 20))
                Spacer()
            }
            .padding()
            .transition(.opacity.animation(.easeInOut))
            
            LazyVStack(alignment: .leading, spacing: 10){
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(eventsSignedUp) { event in
                            NavigationLink{
                                EventDetail(event: event)
                            } label: {
                                EventsCell(event: event, height: height, width: width)
                                    .padding(.vertical)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                    
                }
            }
            .transition(eventsSignedUp.isEmpty ? .opacity.animation(.easeInOut) : .opacity.animation(.easeInOut))
            
        }
        
        
    }
}

struct CircularButton: View {
    var body: some View {
        ZStack (alignment: .center) {
            Circle()
                .fill(.blue)
                .frame(width: 70, height: 70)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
            Text("+")
                .foregroundStyle(.white)
                .font(.system(size: 40))
        }
    }
}
