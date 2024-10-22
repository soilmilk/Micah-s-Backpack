//
//  ContentView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/23/23.
//

import SwiftUI

enum Tabs: String, CaseIterable{
    case events
    case tracker
    case list
    case donate
}
struct ContentView: View {
    
    @Binding var showSignInView: Bool
    @EnvironmentObject private var viewmodel: MyBagViewModel
    @State var notifyCircle = false
    @State var showToolBar = false
    @EnvironmentObject var model: Model
    
    
    //@Environment(\.managedObjectContext) var viewContext
    
    init(showSignInView: Binding<Bool>) {
        UITabBar.appearance().isHidden = true
        self._showSignInView = showSignInView
    }
    
    
    var body: some View {
        
        TabView(selection: $viewmodel.selection) {
            ResponsiveView { layout in
                EventsView(showSignInView: $showSignInView, lp: layout)
                    .navigationTitle("Events")
                    .tag(Tabs.events)
                
            }
            
                MyBagView(showSignInView: $showSignInView, notifyCircle: $notifyCircle)
                    .tag(Tabs.tracker)
            
            
            
            
            ShoppingListView(showSignInView: $showSignInView, notifyCircle: $notifyCircle)
                .tag(Tabs.list)
            
            DonateView(showSignInView: $showSignInView)
                .tag(Tabs.donate)
        }
        .overlay (alignment: .bottom){
            CustomTabBar(selectedTab: $viewmodel.selection, notifyCircle: $notifyCircle)
        }
        .ignoresSafeArea(.keyboard)
        .background(.primaryBg)
        .onAppear {
            withAnimation {
                showToolBar = true
            }
            
        }
        .toolbar{
            if showToolBar {
                ToolbarItem(placement: .topBarLeading) {
                    Text($viewmodel.selection.wrappedValue.rawValue.capitalized)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                    
                }
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink{
                        SettingsView(showSignInView: $showSignInView)
                            .environmentObject(model)
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .tint(.white)
                    }
                }
                
                
            }
            
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.mbpBlue3)
    }
    
    
}


#Preview {
    ContentView(showSignInView: .constant(false))
}
