//
//  UpdateView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/24/24.
//

import SwiftUI
import FirebaseFirestore

class UpdateDonateViewModel: ObservableObject {
    @Published var copyOfBags = 0
    @Published var copyOfItems = 0
    @Published var copyOfMeals = 0
    @Published var showAlert = false
    @Published var description = ""
    
    
    func updateLiveCount(bags: Int, items: Int, meals: Int) async throws {
        let data: [String: Any] = [
            "bags": bags,
            "items": items,
            "meals": meals
        ]
        
        try await Firestore.firestore().collection("data").document("live_count").updateData(data)
    }
    
    @MainActor
    func saveChanges() {
        Task {
            do {
                try await updateLiveCount(bags: copyOfBags, items: copyOfItems, meals: copyOfMeals)
                
            } catch {
                showAlert = true
                description = "Failed to update items."
            }
            
        }
    }
}
struct UpdateDonateView: View {
    @Binding var bags: Int
    @Binding var items: Int
    @Binding var meals: Int
    @Binding var showUpdateView: Bool
    
    
    @StateObject var viewmodel = UpdateDonateViewModel()
    
    var body: some View {
        ZStack {
            Color.primaryBg.ignoresSafeArea()
            VStack {
                HStack {
                    Button("Cancel") {
                        showUpdateView = false
                    }
                    .foregroundStyle(.red)
                    .font(.system(size: 18))
                    Spacer()
                    Button("Update") {
                        viewmodel.saveChanges()
                        
                        if (!viewmodel.showAlert) {
                            bags = viewmodel.copyOfBags
                            meals = viewmodel.copyOfMeals
                            items = viewmodel.copyOfItems
                            
                            showUpdateView = false
                        }
                    }
                    .font(.system(size: 18))
                }
                .font(.system(size: 22))
                .padding(.horizontal)
                .padding(.top, 15)
                
                ItemUpdateView(text: "bags", value: $viewmodel.copyOfBags)
                
                ItemUpdateView(text: "items", value: $viewmodel.copyOfItems)
                
                ItemUpdateView(text: "meals", value: $viewmodel.copyOfMeals)
                Spacer()
            }
            
            
        }
        .onAppear {
            viewmodel.copyOfBags = bags
            viewmodel.copyOfItems = items
            viewmodel.copyOfMeals = meals
        }
        .alert("Alert!", isPresented: $viewmodel.showAlert) {
            Button("OK"){}
        } message: {
            Text(viewmodel.description)
        }
    }
        
    
}


#Preview {
    UpdateDonateView(bags: .constant(10), items: .constant(10), meals: .constant(10), showUpdateView: .constant(true))
}



struct ItemUpdateView: View {
    let text: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(text.uppercased())")
                .font(.headline)
                .bold()
                .foregroundStyle(.secondary)
                .padding(.leading, 10)
            ZStack (alignment: .leading){
                HStack {
                    TextField("Enter the # of \(text)...", value: $value, format: .number)
                        .padding()
                        .font(.system(size: 20))
                    Spacer()
                    
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .frame(height: 50)
        }
        .padding()
    }
}
