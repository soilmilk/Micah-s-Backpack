//
//  ItemDetailView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/17/24.
//

import SwiftUI

struct ItemDetailView: View {
    let itemAnimation: Namespace.ID
    let location: Location
    let bagGoal: Int
    @Binding var notifyCircle: Bool
    let item: ItemData
    let backDidTap: () -> Void
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest (sortDescriptors: []) private var shoppingItems: FetchedResults<ShoppingItem>
    
    @State private var showAlert = false
    @State private var description = ""
    
    @State private var addedTotal = 1
    
    var body: some View {
        VStack (alignment: .leading) {
            ZStack (alignment: .bottom){
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(itemColor.opacity(0.2))
                    .padding(20)
                Image(item.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .matchedGeometryEffect(id: item.name, in: itemAnimation)
                    .frame(width: 200)
                    .padding(.bottom, 50)
                HStack(alignment: .center, spacing: 35){
                    Button("-") {
                        addedTotal -= addedTotal == 1 ? 0 : 1
                    }
                    .tint(.primary)
                    .font(.system(size: 30))
                    Text("\(addedTotal)")
                        .font(.system(size: 30))
                    Button("+") {
                        addedTotal += 1
                    }
                    .tint(.primary)
                    .font(.system(size: 30))
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color.mbpWhite))
            }
            .frame(height: 300)
            
            VStack (alignment: .leading){
                
                Text(item.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                HStack (alignment: .lastTextBaseline, spacing: 5){
                    Text("\(item.per_bag)x")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.green)
                    
                    Text("per bag")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 2)
                 
                Text("Description")
                    .font(.system(size: 25))
                    .padding(5)
                    .bold()
                
                Text(item.desc)
                    .font(.system(size: 15))
                Spacer()
                HStack(alignment: .lastTextBaseline){
                    Text("Current Amount:")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text("\(item.amount)")
                        .fontWeight(.semibold)
                        .foregroundStyle(itemColor)
                        .font(.system(size: 25))
                        .foregroundStyle(.primary)
                    Text("/\(bagGoal * item.per_bag)")
                        .fontWeight(.semibold)
                        .font(.system(size: 25))
                        .foregroundStyle(.primary)
                }
                .padding(.bottom, 5)
                
                Button {
                    self.saveObject(item)
                    notifyCircle = true
                    backDidTap()
                } label: {
                    PrimaryButton(title: .constant("Add to List"), color: .constant(Color.green))
                }
                
                
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
        }
        .padding()
        .matchedGeometryEffect(id: item.id, in: itemAnimation)
        //.frame(width: 320, height: 700)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 40)
        .overlay(Button {
            withAnimation {
                backDidTap()
        }
        } label: {
            XDismissButton()
        }, alignment: .topTrailing)
        .alert("Oops!", isPresented: $showAlert) {
            Button("OK"){}
        } message: {
            Text(description)
        }
    }
    var itemColor: Color {
        let percentAmount = Double(item.amount)/Double(bagGoal * item.per_bag)

        if percentAmount < 0.5 {
            return .red
        } else if percentAmount >= 1{
            return .green
        } else {
            return .yellow
        }
        
    }
    
    func saveObject(_ shopItem: ItemData) {
        if let row = self.shoppingItems.firstIndex(where: {$0.name == shopItem.name && $0.address == location.address}) {
            let current = Int(shoppingItems[row].user_amount ?? "0")!
            shoppingItems[row].user_amount = String(current + addedTotal)

        } else {
            let item = ShoppingItem(context: self.viewContext)
            item.id = shopItem.id
            item.name = shopItem.name
            item.desc = shopItem.desc
            item.amount = String(shopItem.amount)
            item.firebaseRef = shopItem.firebaseRef
            item.done = false
            item.per_bag = String(shopItem.per_bag)
            item.user_amount = String(addedTotal)
            item.address = location.address
            item.addressURL = location.addressURL
        }
 
        do {
            try self.viewContext.save()
        } catch {
            showAlert = true
            description = "Failed to save item."
        }
    }
    
    
}

/*
 #Preview {
 ItemDetailView(location: .constant(false), item: MockData.sampleItemData, bagGoal: 12, isShowingDetail: .constant(true))
 }
 */
