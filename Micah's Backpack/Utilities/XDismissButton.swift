//
//  XDismissButton.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/17/24.
//

import SwiftUI

struct XDismissButton: View {
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 80, height: 80)
                .foregroundStyle(.mbpWhite)
                .opacity(0)
            Image(systemName: "xmark")
                .bold()
                .imageScale(.small)
                .frame(width: 50, height: 50)
                .foregroundStyle(.mbpBlack)
        }
    }
}

#Preview {
    XDismissButton()
}
