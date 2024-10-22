//
//  APButton.swift
//  Appetizers
//
//  Created by Anthony Du on 12/20/23.
//

import SwiftUI

struct PrimaryButton: View {
    
    @Binding var title: String 
    
    @Binding var color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    PrimaryButton(title: .constant("Test Title"), color: .constant(Color.blue))
}
