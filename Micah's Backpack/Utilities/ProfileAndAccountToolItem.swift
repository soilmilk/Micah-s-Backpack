//
//  ProfileAndAccountToolItem.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/29/24.
//

import SwiftUI

struct ProfileAndAccountToolItem: ToolbarContent {
    //@StateObject var model: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            NavigationLink{
                //SettingsView(showSignInView: $showSignInView)
                    //.environmentObject(model)
            } label: {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .tint(.white)
            }
        }

    }
}
