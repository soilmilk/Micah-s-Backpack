//
//  CustomTabBar.swift
//  TestProject0105
//
//  Created by Federico on 01/05/2022.
//

import SwiftUI



struct CustomTabBar: View {
    @Binding var selectedTab: Tabs
    
    @FetchRequest (sortDescriptors: []) private var shoppingItems: FetchedResults<ShoppingItem>
    @Binding var notifyCircle: Bool
    private var tabColor: Color {
        switch selectedTab {
        case .events:
            return .blue
        case .donate:
            return .green
        case .list:
            return .mbpBlack
        case .tracker:
            return .red
        }
    }
    
    private func image(_ tab: Tabs) -> String {
        switch (tab) {
        case .events:
            return "calendar"
        case .donate:
            return "gift"
        case .list:
            return "scroll"
        case .tracker:
            return "mappin.and.ellipse"
        }
        
    }
    
    
    var body: some View {
        HStack {
            ForEach(Tabs.allCases, id: \.rawValue) { tab in
                Spacer()
                ZStack (alignment: .topTrailing){
                    VStack (spacing: 5){
                        Image(systemName: image(tab))
                            .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                            .foregroundStyle(tab == selectedTab ? tabColor : .gray)
                            .font(.system(size: 20))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    selectedTab = tab
                                }
                    }
                        Text(tab.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.medium)
                            .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                            .foregroundStyle(tab == selectedTab ? tabColor : .gray)
                    }
                    if tab == .list {
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(.red)
                            .opacity(notifyCircle ? 1 : 0)
                    }
                    
                }
                
                Spacer()
            }
        }
        .padding(.top)
        .padding(.bottom, 5)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.donate), notifyCircle: .constant(false))
    }
}
