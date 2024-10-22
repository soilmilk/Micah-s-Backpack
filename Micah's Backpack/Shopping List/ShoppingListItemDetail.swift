//
//  ItemDetailView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/17/24.
//

import SwiftUI

struct ShoppingListItemDetail: View {
    let item: ShoppingItem?
    @Binding var showDetailView: Bool
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack (alignment: .leading) {
            ZStack (alignment: .center){
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.blue.opacity(0.2))
                    .padding()
                Image(item?.name ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width/2)
            }
            VStack (alignment: .leading){
                
                Text(item?.name ?? "")
                    .font(.title)
                    .fontWeight(.semibold)
                
                HStack (alignment: .lastTextBaseline, spacing: 5){
                    Text("\(item?.per_bag ?? "0")x")
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
                    .font(.title2)
                    .bold()
                    .padding(.vertical, 5)
                
                Text(item?.desc ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .padding(.vertical, 7)
                Spacer()
            }
            .padding(.leading)
            .padding(.leading)
            .padding(.bottom)
        }
        .frame(width: width*0.9, height: height*0.8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(Button {
            withAnimation(.spring(duration: 0.5)) {
                showDetailView = false
            }      
        } label: {
            XDismissButton()
        }, alignment: .topTrailing)
    }
    
}


#Preview {
    //Breaks previews b/c shoppingItem is CoreData
    ShoppingListItemDetail(item: MockData.sampleShoppingItem, showDetailView: .constant(true), width: 393 ,height: 852)
}
