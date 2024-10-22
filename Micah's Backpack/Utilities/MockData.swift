//
//  Event.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/23/23.
//

import Foundation

struct ItemData: Identifiable, Equatable {
    let id = UUID()
    
    var amount: Int
    let name: String
    let firebaseRef: String
    let desc: String
    let per_bag: Int
    
    init(
        firebaseRef: String,
        per_bag: Int,
        desc: String
    ) {
        self.amount = 0
        self.firebaseRef = firebaseRef
        self.name = firebaseRef.replacingOccurrences(of: "_", with: " ").capitalized
        self.per_bag = per_bag
        self.desc = desc
    }
}


struct MockData {
    
    static var locationItems = [
        ItemData(firebaseRef: "canned_soup", per_bag: 1,
                 desc: "14.75 oz or 7.5 oz microwaveable cup. Examples include chicken noodle or cream of mushroom."),
        ItemData(firebaseRef: "beans_&_franks", per_bag: 1,
                 desc: "7.75 oz or smaller."),
        ItemData(firebaseRef: "tuna", per_bag: 1,
                 desc: "5 oz or smaller can."),
        ItemData(firebaseRef: "canned_pasta", per_bag: 1, desc: "14.75 oz or smaller. Examples include ravioli, pasta rings or spaghetti."),
        ItemData(firebaseRef: "canned_chicken", per_bag: 1, desc: "14.75 oz or smaller."),
        ItemData(firebaseRef: "juice", per_bag: 2, desc: "100% juice box packs, 8 oz. EACH."),
        ItemData(firebaseRef: "snacks", per_bag: 2, desc: "Need to be INDVIDUALLY WRAPPED. Popular ones include Cheese Crackers, Peanut Butter Crackers, Granola Bars, Cereal Bars, Fruit Snacks, and Pretzels."),
        ItemData(firebaseRef: "milk", per_bag: 2, desc: "Box with individual packages."),
        ItemData(firebaseRef:  "oatmeal", per_bag: 1, desc: "Box with individual packages."),
        ItemData(firebaseRef: "mac_n_cheese", per_bag: 1, desc: "Need to be INDIVDUAL CUPS."),
        ItemData(firebaseRef: "fruit_cups", per_bag: 1, desc: "Not to be confused with apple sauce. Can be in served in juice or lite syrup. "),
        ItemData(firebaseRef: "peanut_butter", per_bag: 1, desc: "10.75oz or smaller."),
        ItemData(firebaseRef: "canned_veggies", per_bag: 1, desc: "8 oz or smaller. Examples include corn, peas, green beans, and carrots."),
        ItemData(firebaseRef: "cereal_cups", per_bag: 1, desc: "1oz cups (NOT boxes)")
        
    ]
    static let sampleItemData = ItemData(firebaseRef: "canned_soup", per_bag: 1, desc: "ok")
    static let sampleShoppingItem = ShoppingItem()
    static let sampleDBEvent = DBEvent(
        
        event_id: "1",
        image_path: "images/33DAD830-850F-4029-BEAF-6B55413F2A3C.jpeg",
        name: "Live Music Monata",
        description: "Yo come out",
        address: "MR Real Estate Office, 712 N Main Street",
        cityStateZip: "Blacksburg|VA|24060",
        addressURL: "https://maps.apple.com/?address=712%20N%20Main%20St,%20Unit%20101,%20Blacksburg,%20VA%20%2024060,%20United%20States&auid=9608133263730178016&ll=37.235621,-80.420662&lsp=9902&q=Joe%20Racek%20-%20MR%20Real%20Estate",
        userIdDict: ["Jerry": 2, "Martha": 5, "BOB": 6, "GLADY": 1],
        start_date: Date(),
        end_date: Date(),
        lastUpdated: Date())
    
}




