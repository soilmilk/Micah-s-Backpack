//
//  UpdateView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/24/24.
//

import SwiftUI

class UpdateTrackerViewModel: ObservableObject {
    @Published var copyOfLocationitems = [ItemData]()
    @Published var copyOfGoal = 0
    @Published var showAlert = false
    @Published var description = ""
    
    func saveChanges(location_id: String) {
        Task {
            do {
                var data =  [String: Any]()
                for itemData in copyOfLocationitems {
                    data[itemData.firebaseRef] = itemData.amount
                }
                data["goal"] = copyOfGoal
                
                try await LocationManager.shared.updateItemValues(data: data, location_id: location_id)
            } catch {
                showAlert = true
                description = "Failed to update items."
            }
            
        }
    }
}
struct UpdateTrackerView: View {
    @Binding var locationItems: [ItemData]
    @Binding var goal: Int
    @Binding var location_id: String
    @Binding var showUpdateView: Bool
    
    
    @StateObject var viewmodel = UpdateTrackerViewModel()
    
    var body: some View {
        ZStack {
            Color.primaryBg.ignoresSafeArea()
            
            ScrollView {
                HStack {
                    Button("Cancel") {
                        showUpdateView = false
                    }
                    .foregroundStyle(.red)
                    .font(.system(size: 18))
                    
                    Spacer()
                    Button("Update") {
                        viewmodel.saveChanges(location_id: location_id)
                        
                        if (!viewmodel.showAlert) {
                            locationItems = viewmodel.copyOfLocationitems
                            goal = viewmodel.copyOfGoal
                            showUpdateView = false
                        }
                    }
                }
                .font(.system(size: 18))
                .padding(.horizontal)
                .padding(.bottom, 15)
                
                VStack {
                    HStack {
                        Text("Goal")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    GoalModifierView(goal: $viewmodel.copyOfGoal)
                    HStack {
                        Text("Items")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    ForEach($viewmodel.copyOfLocationitems) {item in
                        ItemModifierView(item: item, goal: goal)
                    }
                }
                
            }
            .padding()
            .scrollIndicators(.hidden)
        }
        .onAppear {
            viewmodel.copyOfLocationitems = locationItems
            viewmodel.copyOfGoal = goal
        }
        .alert("Alert!", isPresented: $viewmodel.showAlert) {
            Button("OK"){}
        } message: {
            Text(viewmodel.description)
        }

    }
}

#Preview {
    UpdateTrackerView(locationItems: .constant([MockData.sampleItemData, MockData.sampleItemData , MockData.sampleItemData]), goal: .constant(50), location_id: .constant(""), showUpdateView: .constant(true))
}

struct ItemModifierView: View {
    
    @Binding var item: ItemData
    let goal: Int
    
    var body: some View {
        
        HStack{
            Image(item.name)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(5)
            
            Text(item.name)
                .bold()
                .font(.system(size: 20))
                .foregroundStyle(.primary)
            
            Spacer()
            HStack(alignment: .center){
                Button{
                    item.amount -= item.amount == 0 ? 0 : 1
                } label: {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("-")
                            .foregroundStyle(.white)
                            .padding(.bottom , 5)
                    }
                }
                .tint(.black)
                .font(.system(size: 30))
                Spacer()
                Text("\(item.amount)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Button {
                    item.amount += 1
                } label: {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("+")
                            .foregroundStyle(.white)
                            .padding(.bottom , 5)
                    }
                }
                .tint(.black)
                .font(.system(size: 30))
            }
            .frame(width: 140, height: 80)
            .padding()
            
        }
        .frame(width: 380, height: 80)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(itemColor.opacity(0.25))
        )
        .padding(5)
    }
    
    var itemColor: Color {
        let percentAmount = Double(item.amount)/Double(goal * item.per_bag)

        if percentAmount < 0.5 {
            return .red
        } else if percentAmount >= 1{
            return .green
        } else {
            return .yellow
        }
        
    }
}

struct GoalModifierView: View {
    @Binding var goal: Int
    var body: some View {
        HStack{
            Image(systemName: "flag.fill")
                .resizable()
                .foregroundStyle(.blue)
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.horizontal, 10)
            
            Text("Goal")
                .bold()
                .font(.system(size: 25))
            
            Spacer()
            HStack(alignment: .center){
                Button{
                    goal -= goal == 1 ? 0 : 1
                } label: {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("-")
                            .foregroundStyle(.white)
                            .padding(.bottom , 5)
                    }
                }
                .tint(.black)
                .font(.system(size: 30))
                Spacer()
                Text("\(goal)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Button {
                    goal += 1
                } label: {
                    ZStack (alignment: .center){
                        RoundedRectangle(cornerRadius: 5).fill(Color.blue)
                            .frame(width: 30, height: 30)
                        Text("+")
                            .foregroundStyle(.white)
                            .padding(.bottom , 5)
                    }
                }
                .tint(.black)
                .font(.system(size: 30))
                .background()
            }
            .frame(width: 140, height: 50)
            .padding()
            
        }
        .padding()
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(.mbpWhite)
        )
        .padding(5)
    }
}
