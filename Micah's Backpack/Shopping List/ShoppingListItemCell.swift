//
//  AppetizerListCell.swift
//  Appetizers
//
//  Created by Anthony Du on 12/19/23.
//

import SwiftUI

struct ShoppingListItemCell: View {
    
    var item: ShoppingItem
    @Environment(\.managedObjectContext) var viewContext
    let width: CGFloat
    var body: some View {
        
        HStack {
            Button {
                item.done.toggle()
                do {
                    try self.viewContext.save()
                } catch {
                    
                }
                
            } label: {
                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.gray)
                    .dynamicTypeSize(.xxxLarge)
            }
            ZStack (alignment: .center){
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white)
                    .frame(width: width/6, height: width/6)
                Image(item.name ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width/6, height: width/6)
            }
            
            VStack (alignment: .leading, spacing: 5) {
                Text(item.name ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(item.per_bag ?? "1")x per bag")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            Spacer()
            Text(item.user_amount ?? "")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal)
                .background(.blue)
                .clipShape(Capsule())
        }
        .background(Color.primaryBg)

        
    }
}


 

