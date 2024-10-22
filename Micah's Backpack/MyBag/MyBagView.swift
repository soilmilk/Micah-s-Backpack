//
//  MyBagView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/4/24.
//

import SwiftUI
import _MapKit_SwiftUI
import FirebaseFirestore


struct Location: Identifiable, Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.doc.documentID == rhs.doc.documentID
    }
    
    let id = UUID()
    let doc: DocumentSnapshot
    let coordinate: CLLocationCoordinate2D
    let address: String
    let addressURL: String
    let deadline: Date
    let isGoalMet: Bool
}

struct MyBagView: View {
    @Binding var showSignInView: Bool
    @Binding var notifyCircle: Bool
    @Namespace private var itemAnimation
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible())]
    @FetchRequest (sortDescriptors: [SortDescriptor(\ShoppingItem.address)]) private var shoppingItems: FetchedResults<ShoppingItem>
    @Environment(\.managedObjectContext) var viewContext
    

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.229572, longitude: -80.413940), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    @State var selectedDetent: PresentationDetent = .large
    
    @State var showInfoView: Bool = false
    @State var showAddTrackerView: Bool = false
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var viewmodel: MyBagViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Spinner(size: 50)
                    .opacity(viewmodel.doneLoading ? 0 : 1)
                
                Map(coordinateRegion: $region, annotationItems: viewmodel.locations) { loc in
                    
                    MapAnnotation(coordinate: loc.coordinate) {
                        Button {
                            viewmodel.selectedLocation = loc
                            viewmodel.showTrackerView = true
                        } label: {
                            PlaceAnnotationView(isGoalMet: loc.isGoalMet)
                        }
                        
                    }
                }
                
                VStack (spacing: 10) {
                    if let result = UserManager.shared.currentDBUser?.isAdmin {
                        if result {
                            HStack {
                                Spacer()
                                Button {
                                    showAddTrackerView = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .tint(.blue)
                                        .frame(width: 40, height: 40)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .blue)
                                }
                            }
                        }
                    }
                    
                    
                    HStack {
                        Spacer()
                        Button {
                            showInfoView = true
                        } label: {
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .blue)
                                
                        }
                        .padding(.top)
                    }
                    
                }
                .padding(.top)
                .padding(.trailing)
                
                
                
            }
            .onChange(of: viewmodel.locations) {_ in
                if !viewmodel.locations.isEmpty {
                    withAnimation(.easeInOut.speed(0.5)) {
                        region = viewmodel.regionThatFitsTo(coordinates: viewmodel.locations.map {$0.coordinate})
                    }
                    
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(isPresented: $viewmodel.showTrackerView) {
                trackerView
            }
            .sheet(isPresented: $showInfoView){
                InfoView()
            }
            .sheet(isPresented: $showAddTrackerView, content: {
                AddTrackerView(locations: $viewmodel.locations)
            })
            
        }
        .onAppear {
            viewmodel.getLocations() {}
            
        }
        .alert("Oops!", isPresented: $viewmodel.showAlert) {
            Button("OK"){}
        } message: {
            Text(viewmodel.description)
        }
    }
    
    var trackerView: some View {
        ZStack {
            VStack {
                NavigationStack {
                    ScrollView {
                        HStack {
                            CircularProgress(value: $viewmodel.value, displayedValue: $viewmodel.displayedValue)
                                .padding()
                            VStack {
                                DataView(text: "\(viewmodel.goal)", systemImage: "flag.fill", desc: "Goal", color: .blue)
                                DataView(text: "\(viewmodel.selectedLocation?.deadline.formatted(.dateTime.day().month()) ?? "Dec 31")", systemImage: "calendar", desc: "Deadline", color: .red)
                                DataView(text: "\(viewmodel.urgentItems)", systemImage: "exclamationmark.triangle.fill", desc: "Urgent Items", color: .yellow)
                            }
                        }
                        .padding(5)

                        Button {
                            openURL(URL(string: viewmodel.selectedLocation?.addressURL ?? "")!) { canOpen in
                                if (!canOpen){
                                    viewmodel.showAlert = true
                                    viewmodel.description = "Failed to load."
                                }
                            }
                        } label: {
                            HStack (spacing: 10){
                                Image(systemName: "shippingbox")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                Text("Drop Off:")
                                    .bold()
                                Text(viewmodel.selectedLocation?.address ?? "")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .fill(.mbpWhite)
                            )
                            .padding(.horizontal)
                            .foregroundStyle(.mbpBlack)
                        }
                    
    
                        if let result = UserManager.shared.currentDBUser?.isAdmin {
                            if result {
                                HStack (alignment: .top){
                                    Button {
                                        viewmodel.showUpdateView = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                    .foregroundStyle(Color.mbpBlue2)
                                    Spacer()
                                    
                                    Button {
                                        deleteTracker()
                                    } label: {
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                    .foregroundStyle(.red)
                                    
                                }
                                .padding()
                            }
                        }
                        
                        
                        HStack {
                            Text("Items")
                                .fontWeight(.bold)
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                        }
                        SearchBar(text: $viewmodel.searchTerm)
                            .padding(.bottom)
                            .padding(.horizontal)
                        
                        
                        LazyVGrid(columns: columns) {
                            ForEach(viewmodel.locationItems.filter({"\($0)".contains(viewmodel.searchTerm.lowercased()) || viewmodel.searchTerm.isEmpty})) { locationItem in
                                
                                if (viewmodel.selectedItem != locationItem) {
                                    ItemCell(itemAnimation: itemAnimation, bagItem: locationItem, bagGoal: viewmodel.goal)
                                        .onTapGesture {
                                            withAnimation(.spring) {
                                                viewmodel.selectedItem = locationItem
                                            }
                                    }
                                }     
                            }
                        }
                        .padding(5)
                        .animation(.spring, value: viewmodel.searchTerm)
                        
                        
                    }
                    .task {
                        await onStartUp()
                    }
                    .background(.primaryBg)
                    .scrollIndicators(.hidden)
                    
                }
                
            }
            //.blur(radius: viewmodel.isShowingDetail ? 20: 0)
            
            
            if let selectedItem = viewmodel.selectedItem {
                ItemDetailView(itemAnimation: itemAnimation, location: viewmodel.selectedLocation!, bagGoal: viewmodel.goal, notifyCircle: $notifyCircle, item: selectedItem) {
                    withAnimation {
                        viewmodel.selectedItem = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoView) {
            InfoView()
        }
        .sheet(isPresented: $viewmodel.showUpdateView, onDismiss: {
            Task {
                await onStartUp()
            }
            
        }, content: {
            UpdateTrackerView(locationItems: $viewmodel.locationItems, goal: $viewmodel.goal, location_id: $viewmodel.locationId, showUpdateView: $viewmodel.showUpdateView )
        })
        .presentationDetents([.large] ,selection: $selectedDetent)
        .presentationDragIndicator(.visible)
    }
    
    @MainActor
    func onStartUp() async {
        viewmodel.locationItems = MockData.locationItems
        await viewmodel.getItems()
        
        withAnimation(.spring().speed(0.2)) {
            viewmodel.startTimer()
        }
    }
    func deleteTracker() {
        viewmodel.deleteLocation() {address in
            if let address = address {
                for item in shoppingItems {
                    if item.address == address {
                        viewContext.delete(item)
                    }
                }
                do {
                    try viewContext.save()
                } catch {
                    viewmodel.showAlert = true
                    viewmodel.description = "Oops! Something went wrong."
                }
            }
            
        }
    }
}



struct NumValue: View {
    var displayedValue = 0
    var color: Color
    var body: some View {
        VStack {
            Text("\(displayedValue)")
                .bold()
                .font(.title)
                .foregroundStyle(color)
            Text("Bags Filled")
                .bold()
                .font(.title3)
                .foregroundStyle(color)
        }
        
    }
}

#Preview {
    MyBagView(showSignInView: .constant(true), notifyCircle: .constant(false))
}

struct CircularProgress: View {
    @Binding var value: Double
    @Binding var displayedValue: Int
    
    var body: some View {
        ZStack{
            Circle()
                .stroke(lineWidth: 15)
                .frame(width: 150, height: 150)
                .foregroundStyle(Color.mbpWhite)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
            
            Circle()
                .stroke(lineWidth: 0.5)
                .frame(width: 140, height: 140)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.primary.opacity(0.3), .clear]), startPoint: .bottomTrailing, endPoint: .topLeading))
                .overlay {
                    Circle()
                        .stroke(.primary.opacity(0.1), lineWidth: 10)
                        .blur(radius: 5)
                        .mask {
                            Circle()
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.primary, .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                }
            Circle()
                .trim(from: 0, to: value)
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            
            NumValue(displayedValue: displayedValue, color: .primary)
            
        }
    }
}

struct DataView: View {
    let text: String
    let systemImage: String
    let desc: String
    let color: Color
    
    
    var body: some View {
        HStack {
            HStack (alignment: .center, spacing: 10) {
                Image(systemName: systemImage)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(color)
                Text(text)
                    .bold()
                    .font(.system(size: 15))
                Text(desc)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15))
            }
            Spacer()
        }
        .padding(.leading)
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(.mbpWhite)
        )
    }
}


struct PlaceAnnotationView: View {
    let isGoalMet: Bool
  
    var body: some View {
    VStack(spacing: 0) {
        
        ZStack (alignment:.center){
            Image(systemName: "circle.fill")
            .font(.system(size: 30))
            .foregroundColor(isGoalMet ? .green : .red)
            
            Image(systemName: isGoalMet ? "checkmark.gobackward" : "mappin.and.ellipse")
                .font(.system(size: isGoalMet ? 20 : 18))
            .foregroundColor(.white)
            
            
        }
        

      Image(systemName: "arrowtriangle.down.fill")
        .font(.system(size: 13))
        .foregroundColor(isGoalMet ? .green : .red)
        .offset(x: 0, y: -5)
    }
  }
}
