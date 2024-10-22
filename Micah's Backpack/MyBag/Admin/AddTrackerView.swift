//
//  AddTrackerView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/31/24.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

struct AddTrackerView: View {
    @StateObject private var mapSearch = MapSearch()
    @Binding var locations: [Location]
    
    func reverseGeo(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }
            
            if let c = coordinateK {
                self.location = c
                
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        showAlert = true
                        description = "Unable to load addresses. Check your network connection."
                        return
                    }
                    
                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    
                    address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName), \(reversedGeoLocation.city) \(reversedGeoLocation.state)"
                    city = "\(reversedGeoLocation.city)"
                    state = "\(reversedGeoLocation.state)"
                    zip = "\(reversedGeoLocation.zipCode)"
                    mapSearch.searchTerm = address
                    isFocused = false
                    
                }
            }
        }
    }
    
    func saveState() async -> Bool {
        
        if goal == 0 || address.isEmpty {
            showAlert = true
            description = "One or more fields is empty."
            return false
        }
        
        guard let loc = location else {
            return false
        }
        
        acceptSubmissions = false
        do {
            let id = try await LocationManager.shared.createLocation(deadline: deadline, goal: goal, lat: loc.latitude, lon: loc.longitude, address: address, type: protein)
            
            let doc = try await LocationManager.shared.getLocation(id: id)
            
            locations.append(
                Location(
                    doc: doc,
                    coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude),
                    address: address,
                    addressURL: "maps://?saddr=&daddr=\(loc.latitude),\(loc.longitude)",
                    deadline: deadline,
                    isGoalMet: false)
            )

        } catch {
            showAlert = true
            description = "Failed to create."
            acceptSubmissions = true
            return false
        }
        acceptSubmissions = true
        return true
    }
    @State private var acceptSubmissions: Bool = true
    @FocusState private var isFocused: Bool
    
    @State private var isPressed = false
    
    @State private var btnHover = false
    @State private var isBtnActive = false
    
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var location: CLLocationCoordinate2D? = nil
    
    @State private var goal: Int = 0
    @State private var deadline: Date = Date.now
    
    @State private var showAlert = false
    @State private var description = ""
    
    @State private var protein: Protein = .beans_and_franks
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        List {
            Section {
                Text("Start typing an address and you will see a list of possible matches.")
                    .font(.system(size: 18))
                TextField("Address", text: $mapSearch.searchTerm)
                    .font(.system(size: 18))
                
                if address != mapSearch.searchTerm && isFocused == false {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        Button {
                            reverseGeo(location: location)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(location.title)
                                    .foregroundStyle(Color.blue)
                                    .font(.system(size: 18))
                                Text(location.subtitle)
                                    .font(.system(.caption))
                                    .foregroundStyle(Color.blue)
                                    .font(.system(size: 18))
                            }
                        }
                    }
                }
                
                TextField("City", text: $city)
                    .font(.system(size: 18))
                TextField("State", text: $state)
                    .font(.system(size: 18))
                TextField("Zip", text: $zip)
                    .font(.system(size: 18))
                
            } header: {
                Text("Address")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundStyle(.secondary)
            }
            .listRowSeparator(.visible)
            
            Section{
                DatePicker("Date", selection: $deadline)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(.vertical, 5)
                    .font(.system(size: 18))
            } header: {
                Text("Deadline")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundStyle(.secondary)
                    .font(.system(size: 18))
            }
            Section {
                Picker("Type",
                      selection: $protein) {
                    ForEach(Protein.allCases) { protein in
                        Text(protein.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                           }
                }
                      .pickerStyle(.automatic)
                
            } header: {
                Text("Protein")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundStyle(.secondary)
                    .font(.system(size: 18))
            }
            
            
            VStack(alignment: .leading) {
                Text("GOAL")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundStyle(.secondary)
                ZStack (alignment: .leading){
                    HStack {
                        TextField("Enter the goal amount ...", value: $goal, format: .number)
                            .padding(10)
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        
                    }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
            }
            .listRowBackground(Color.primaryBg)
            .listRowSeparator(.hidden)
            .padding(.vertical)
            
            PrimaryButton(title: .constant("Create"), color: .constant(Color.mbpBlue3))
                .scaleEffect(isPressed ? 1.05 : 1.0)
                .opacity(isPressed ? 0.6 : 1.0)
                .onTapGesture {
                    Task {
                        if await (saveState()) {
                            dismiss()
                        }
                    }
                }
                .pressEvents {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                } onRelease: {
                    withAnimation {
                        isPressed = false
                    }
                }
                .listRowBackground(Color.primaryBg)
                .padding(.vertical)
            
            
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .background(Color.primaryBg)
        .alert("Oops!", isPresented: $showAlert) {
            Button("OK"){}
        } message: {
            Text(description)
        }
    }
}

#Preview {
    AddTrackerView(locations: .constant([Location]()))
}

enum Protein: String, CaseIterable, Identifiable {
    case chicken
    case tuna
    case peanut_butter
    case beans_and_franks
    
    var id: Self { self }
}
