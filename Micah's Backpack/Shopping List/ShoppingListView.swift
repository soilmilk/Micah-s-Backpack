//
//  ShoppingListView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/17/24.
//

import SwiftUI

struct ShoppingListView: View {
    @Binding var showSignInView: Bool
    @Binding var notifyCircle: Bool
    
    @FetchRequest (sortDescriptors: [SortDescriptor(\ShoppingItem.address)]) private var shoppingItems: FetchedResults<ShoppingItem>
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.openURL) private var openURL
    
    @State private var showAlert = false
    @State private var description = ""
    
    @State var showDetailView: Bool = false
    @State var selectedItem: ShoppingItem? = nil
    
    @State var groups: [[ShoppingItem]] = [[ShoppingItem]]()
    

    var body: some View {
        ZStack {
            GeometryReader { r in
                Color.primaryBg
                NavigationStack {
                    ZStack (alignment: .center){
                        List {
                            ForEach(groups, id: \.self) {items in
                                Section {
                                    HStack {
                                        Text(items[0].address ?? "")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Button {
                                            openURL(URL(string: items[0].addressURL ?? "")!) { canOpen in
                                                if (!canOpen){
                                                    showAlert = true
                                                    description = "Failed to load."
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "paperplane")
                                                .foregroundStyle(.blue)
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    ForEach(items, id: \.self) { item in
                                        Button {
                                            withAnimation(.spring) {
                                                showDetailView = true
                                            }
                                            selectedItem = item
                                        } label: {
                                            ShoppingListItemCell(item: item, width: r.size.width)
                                        }
                                        .padding(.vertical, 5)

                                    }
                                    .onDelete {self.delete(at: $0, in: items)}
                                    
                                }
                                .listRowBackground(Color.primaryBg)
                                .listRowInsets(EdgeInsets())
                                //.listRowSeparator(.hidden, edges: .all)
                                
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .scrollIndicators(.hidden)
                        .listRowSeparator(.visible, edges: .all)
                        .opacity(shoppingItems.isEmpty ? 0 : 1)
                        .padding(.bottom, 50)
                        
                        
                        EmptyState(imageString: "empty_list", message: "You have no items added to your shopping list. Go add some!", height: r.size.height / 2.5)
                            .opacity(shoppingItems.isEmpty ? 1 : 0)
                        
                        if (showDetailView){
                            ShoppingListItemDetail(item: selectedItem, showDetailView: $showDetailView, width: r.size.width, height: r.size.height)
                                .transition(.push(from: .top))
                        }
                        
                    }
                }
                .navigationTitle("Shopping List")
                .scrollContentBackground(.hidden)
                .background(Color.primaryBg)
                
                
            }
            
            
        }
        .alert("Oops!", isPresented: $showAlert) {
            Button("OK"){}
        } message: {
            Text(description)
        }
        .onAppear {
            notifyCircle = false
            groups = [_](Dictionary(grouping: shoppingItems, by: \.address).values)
        }
        
        
        
    }
    
    private func delete(at offsets: IndexSet, in items: [ShoppingItem]) {
        for index in offsets {
            groups[groups.firstIndex(of: items)!].remove(at: index)
            self.viewContext.delete(items[index])
            groups = groups.filter {!$0.isEmpty}
            
            do {
                try viewContext.save()
                
            } catch {
                showAlert = true
                description = "Failed to delete item."
            }
        }
    }
    
}


/*
#Preview {
    ShoppingListView(showSignInView: .constant(false), notifyCircle: .constant(false), lp: getPreviewLayoutProperties(height: 667, width: 375))
}
 */


struct EmptyState: View {
    let imageString: String
    let message: String
    let height: CGFloat
    var body: some View {
        
        ZStack {
            Color(.primaryBg)
                .ignoresSafeArea()
            VStack {
                Image(imageString)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            
        }
        .frame(maxHeight: .infinity)
    }
}
