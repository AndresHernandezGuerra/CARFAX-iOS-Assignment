//
//  CarListings.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/18/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import Foundation

class CarListing {
    
    var arrayListing:[ListingItem] = []
    
    public static let sharedInstance = CarListing()
    
    private init() {
        self.arrayListing = []
    }
    
    public func add(myTitle: String, myDescription: String) {
        arrayListing.append(ListingItem(title: myTitle, description: myDescription))
    }
}

struct ListingItem {
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}
