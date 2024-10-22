//
//  SearchBar.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/17/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    var body: some View {
        HStack {
            TextField("Search here...", text: $text)
                .padding(15)
                .padding(.horizontal, 25)
                .background(Color.searchBarBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        
                        if isEditing {
                            Button {
                                self.text = ""
                            } label: {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundStyle(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                        
                    }
                ).onTapGesture {
                    self.isEditing = true
                }
            if isEditing{
                Button {
                    self.isEditing = false
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16))
                }
                .padding(.trailing, 10)
                
            }
        }
    }
}

#Preview {
    SearchBar(text: .constant("1"))
}
