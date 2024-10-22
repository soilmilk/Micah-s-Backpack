//
//  EventCreator.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 1/10/24.
//

import SwiftUI
import PhotosUI


struct EventCreator: View {
    
    @StateObject private var viewmodel =  EventCreatorViewModel()
    @Environment(\.dismiss) var dismiss
    @Binding var event: DBEvent
    @FocusState private var isFocused: Bool
    @StateObject var mapSearch = MapSearch()
    
    @State private var isPressed = false
    
    var isNewEvent: Bool
    
    var body: some View {
        ZStack (alignment: .top) {
            Color.primaryBg.ignoresSafeArea()
            VStack {
                Text(isNewEvent ? "Create New Event" : "Edit Event")
                    .bold()
                    .font(.system(size: 16))
                
                List {
                    SectionView(
                        bindingString: $viewmodel.name,
                        sectionHeader: "Name",
                        sectionText: "Name of Event")
                    
                    SectionView(
                        bindingString: $viewmodel.description,
                        sectionHeader: "Description",
                        sectionText: "Description of Event")
                    
                    Section {
                        Text("Start typing an address and you will see a list of possible matches.")
                        TextField("Address", text: $mapSearch.searchTerm)
                        
                        if viewmodel.address != mapSearch.searchTerm && isFocused == false {
                            ForEach(mapSearch.locationResults, id: \.self) { location in
                                Button {
                                    viewmodel.reverseGeo(location: location, mapSearch: mapSearch)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(location.title)
                                            .foregroundColor(Color.blue)
                                        Text(location.subtitle)
                                            .font(.system(.caption))
                                            .foregroundColor(Color.blue)
                                    }
                                }
                            }
                        }
                        
                        TextField("City", text: $viewmodel.city)
                        TextField("State", text: $viewmodel.state)
                        TextField("Zip", text: $viewmodel.zip)
                        
                        
                    } header: {
                        Text("Address")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.visible)
                    
                    Section {
                        PhotosPicker(selection: $viewmodel.selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("Select a photo")
                        }
                        viewmodel.selectedImage?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        if (viewmodel.selectedImage == nil && viewmodel.url != nil) {
                            AsyncImage(url: viewmodel.url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Spinner(size: 30)
                                    .frame(width: 150, height:  150)
                            }
                        }
                    } header: {
                        Text("Event Image")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    
                    Section {
                        DatePicker("Start Date:", selection: $viewmodel.start_date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.vertical, 5)
                        
                        DatePicker("End Date:", selection: $viewmodel.end_date, in: viewmodel.start_date...)
                            .datePickerStyle(CompactDatePickerStyle())
                            .padding(.vertical, 5)
                    } header: {
                        Text("Date")
                            .font(.headline)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                    
                    PrimaryButton(title: .constant(isNewEvent ? "Create a new Event" : "Save Event"), color: .constant(Color.mbpBlue3))
                        .scaleEffect(isPressed ? 1.05 : 1.0)
                        .opacity(isPressed ? 0.6 : 1.0)
                        .onTapGesture {
                            Task {
                                if viewmodel.acceptSubmissions {
                                    let success = await viewmodel.createOrEditEvent(isNewEvent: isNewEvent, event: event)
                                    if (success){
                                        if let updatedEvent = viewmodel.updatedEvent {
                                            event = updatedEvent
                                        }
                                        dismiss()
                                    }
                                    
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
                    
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
            
            
            HStack {
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.mbpBlue2)
                    Text("Cancel")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                        .foregroundStyle(.mbpBlue2)
                }
                .padding(.leading)
                Spacer()
            }
            
            
        }
        .toolbar(.hidden)
        .onAppear {
            self.isFocused = viewmodel.isFocusNeeded
            if (!isNewEvent){
                Task {
                    await viewmodel.showCurrentEventValues(event: event, mapSearch: mapSearch)
                }
                
            }
        }
        .alert("Alert!", isPresented: $viewmodel.showAlert) {
            Button("OK"){}
        } message: {
            Text(viewmodel.alertDescription)
        }
        .onChange(of: viewmodel.selectedItem) { newValue in
            Task {
                if let loaded = try? await viewmodel.selectedItem?.loadTransferable(type: Image.self) {
                    viewmodel.selectedImage = loaded
                } else {
                    viewmodel.alertDescription = "Failed to select image."
                    viewmodel.showAlert = true
                }
            }
        }
        .onChange(of: isFocused) { viewmodel.isFocusNeeded = $0 }
        .onChange(of: viewmodel.isFocusNeeded) { isFocused = $0 }
   
    }
}


#Preview {
    EventCreator(event: .constant(MockData.sampleDBEvent), isNewEvent: false)
}

struct SectionView: View {
    
    @Binding var bindingString: String
    var sectionHeader: String
    var sectionText: String
    var body: some View {
        Section {
            TextField(text: $bindingString, prompt: Text(sectionText), axis: .vertical) {
            }
            .ignoresSafeArea(.keyboard)
            .dynamicTypeSize(...DynamicTypeSize.xSmall)
        } header: {
            Text(sectionHeader)
                .bold()
                .foregroundStyle(.secondary)
                .dynamicTypeSize(.small)
        }
    }
}


