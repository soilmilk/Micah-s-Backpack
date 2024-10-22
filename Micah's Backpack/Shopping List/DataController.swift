//
//  DataController.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 3/22/24.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Shopping")
    @Published var shoppingItems: [ItemData] = [ItemData]()
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
            }
        }
    }
}
