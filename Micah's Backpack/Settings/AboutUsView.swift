//
//  AboutUsView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/30/24.
//

import SwiftUI

struct AboutUsView: View {
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.mbpBlue2)
                    Text("Back")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.mbpBlue2)
                }
                
                Spacer()
            }
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.vertical)
               
            
            Text("Micah’s Backpack addresses children’s hunger issues by partnering with local schools to provide direct assistance to students and families who qualify for the free lunch program.")
            HStack {
                Text("Each week during the school year, the identified students receive a backpack filled with enough food for the weekend. The backpacks include two dinners, two lunches and two breakfasts. ")
                    .multilineTextAlignment(.leading)
                Image("packing_bags")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(height: 200)
            }
            .padding(.vertical)

            Text("Weekly, nearly") + Text(" 70 volunteers ").bold() +  Text("from various academic, civic, and religious groups work together building community while packing the backpacks and the partner schools distribute the backpacks to the students. ")
            Image("bus")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("Each Friday, approximately") + Text(" 300 students at 10 Blacksburg schools ").bold() + Text("each receive") + Text(" 6 meals of healthy foods ").bold() + Text("to include milk, juice boxes and snacks.") + Text("\n\nMicah’s Backpack invites the members of our community to join us in the fight against food insecurity in our schools.")
            Text("")
                .padding(.bottom, 100)
        }
        .fontWeight(.light)
        .padding(.horizontal)
        .scrollIndicators(.hidden)
        .toolbar(.hidden)
        .background(Color.primaryBg)
        
    }
}

#Preview {
    AboutUsView()
}
