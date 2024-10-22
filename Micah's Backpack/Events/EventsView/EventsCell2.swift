//
//  EventsCell2.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 4/8/24.
//

import SwiftUI

struct EventsCell2: View {
    var event: DBEvent
    
    var body: some View {
        ZStack {
            Color.primaryBg.ignoresSafeArea()
        
        HStack {
            CachedImage(imgPath: event.image_path, animation: .bouncy) {phase in
                switch phase {
                case .empty:
                    Spinner(size: 50)
                        .frame(width: 100, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical)
                case .failure(_):
                    Image("backpack")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.vertical)
                    
                @unknown default:
                    EmptyView()
                }
            }
            VStack (alignment: .leading) {
                Text(event.start_date.formatted(.dateTime.month().day().hour().minute(.defaultDigits)))
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                Text(event.name)
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .bold()
                .font(.system(size: 20))
            
        }
        .padding(.horizontal)
        .background(Color.mbpWhite)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
    }
}

#Preview {
    EventsCell2(event: MockData.sampleDBEvent)
}
