//
//  AppetizerListCell.swift
//  Appetizers
//
//  Created by Anthony Du on 12/19/23.
//

import SwiftUI


struct EventsCell: View {
    var event: DBEvent
    let height: CGFloat
    let width: CGFloat
    
    var body: some View {
      
        VStack {
            ZStack (alignment: .topTrailing) {
                ZStack (alignment: .bottom){
                    CachedImage(imgPath: event.image_path, animation: .bouncy) {phase in
                        switch phase {
                        case .empty:
                            Spinner(size: 75)
                                .frame(width: width, height: height)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: width, height: height)
                        case .failure(_):
                            Image("backpack")
                                .resizable()
                                .aspectRatio(contentMode: .fit)   
                                .frame(width: width, height: height)
                        @unknown default:
                            EmptyView()
                                .frame(width: width, height: height)
                        }
                        
                    }
                      
                    HStack {
                        VStack(alignment: .listRowSeparatorLeading) {
                            Text(event.name)
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text(event.start_date.formatted(.dateTime.hour().minute()))
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        Spacer()
                        
                    }
                    .background(.ultraThinMaterial)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack{
                    Text(event.start_date.formatted(.dateTime.month(.abbreviated)).uppercased())
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                    Text(event.start_date.formatted(.dateTime.day()))
                        .fontWeight(.heavy)
                        .font(.system(size: 30))
                        .foregroundStyle(.white)
                }
                .frame(width: 70, height: 70)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(5)
            }
            
            
            HStack {
                Image(systemName: "person")
                    .resizable()
                    .bold()
                    .frame(width: 23, height: 25)
                    .foregroundStyle(.secondary)
                
                Text("\(event.userIdDict.count)")
                    .fontWeight(.heavy)
                    .font(.system(size: 23))
                    .foregroundStyle(.secondary)
                Spacer()
                
                Text("More Details")
                    .bold()
                    .font(.system(size: 20))
                    .padding()
                    .foregroundStyle(.white)
                .background(.purple)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
        }
        .padding()
        .background(Color.mbpWhite)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)

        
    }
}


#Preview {
    EventsCell(event: MockData.sampleDBEvent, height: 300, width: 320)
}
