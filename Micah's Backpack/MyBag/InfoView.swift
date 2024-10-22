//
//  InfoView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 4/28/24.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack {
                InfoDetailView(image: "mappin.and.ellipse", title: "Click on a Tracker", desc: "Places in need will be marked red.", color: .red)
                
                InfoDetailView(image: "eye.fill", title: "Check the status", desc: "Guage how close the number of bags is to the goal, as well as the deadline.", color: .blue)
                
                InfoDetailView(image: "rectangle.portrait.badge.plus.fill", title: "Add Necessary Items", desc: "Each bag needs 11 types of items.", color: .green)
                
                InfoDetailView(image: "scroll", title: "Use your List", desc: "All your added items will be present for when you go shopping.", color: .primary)
                
                InfoDetailView(image: "shippingbox", title: "Drop Off", desc: "Drop the items off at the tracker's location.", color: .brown)
                
                InfoDetailView(image: "clock.arrow.circlepath", title: "Track the Progress", desc: "A volunteer at the tracker will update the item counts, bringing it closer to the goal!", color: .purple)
                
                
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
        .padding(.vertical)
        
    }
}

#Preview {
    InfoView()
}

struct InfoDetailView: View {
    let image: String
    let title: String
    let desc: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(color)
                .padding(.trailing)
            
            VStack (alignment: .leading){
                Text(title)
                    .bold()
                    .foregroundStyle(.primary)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                Text(desc)
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
              
        }
        .padding()
    }
}
