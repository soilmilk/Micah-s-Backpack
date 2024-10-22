//
//  ItemCell.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/6/24.
//

import SwiftUI

struct ItemCell: View {
    let itemAnimation: Namespace.ID
    let bagItem: ItemData
    let bagGoal: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(.mbpWhite)
            .matchedGeometryEffect(id: bagItem.id, in: itemAnimation)
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            VStack{
                Image(bagItem.name)
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: bagItem.name, in: itemAnimation)
                    .frame(width: 160, height: 80)
                    
                
                Spacer()
                
                Text(bagItem.name)
                    .bold()
                    .font(.system(size: 20))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Text("\(bagItem.per_bag)x per bag")
                    .fontWeight(.medium)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                HStack {
                    Text("\(bagItem.amount)/\(bagGoal * bagItem.per_bag)")
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                    Spacer()
                    HStack{
                        VStack {
                            Text(status)
                                .fontWeight(.bold)
                                .font(.system(size: 15))
                                .foregroundStyle(itemColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .lineLimit(1)
                        }
                        .background(itemColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    }
                    
                }
                
            }
            .padding()
        }
        
        
        
        
    }
    
    var itemColor: Color {
        let percentAmount = Double(bagItem.amount)/Double(bagGoal * bagItem.per_bag)

        if percentAmount < 0.5 {
            return .red
        } else if percentAmount >= 1{
            return .green
        } else {
            return .yellow
        }
        
    }
    var status: String {
        switch itemColor {
        case .red:
            return "Urgent"
        case .yellow:
            return "Low"
        case .green:
            return "Good"
        default:
            return "Good"
        }
    }
}


/*
 #Preview {
 ItemCell(itemAnimation: , bagItem: MockData.sampleItemData, bagGoal: 220)
 }
 */
