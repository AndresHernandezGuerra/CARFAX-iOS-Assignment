//
//  CarDetailedInfo.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/18/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import Foundation

// MARK: - Car Properties 
struct CarDetails: Codable {
    
    let listingID               :       String?
    let carYear                 :       Int?
    let carMake                 :       String?
    let carModel                :       String?
    let carMileage              :       Int?
    let carPrice                :       Int?
  
    let dealer                  :       DealerDetails?
    let carThumbnail            :       CarThumbnail?
    
    enum CodingKeys: String, CodingKey {
        case listingID          =       "id"
        case carYear            =       "year"
        case carMake            =       "make"
        case carModel           =       "model"
        case carMileage         =       "mileage"
        case carPrice           =       "currentPrice"

        case dealer             =       "dealer"
        case carThumbnail       =       "images"
    }
}

// MARK: - Struct to Access All Photos
struct CarThumbnail: Codable {
    
    let firstPhoto              :       CarImages?
    
    enum CodingKeys: String, CodingKey {
        case firstPhoto         =       "firstPhoto"
    }
}

// MARK: - Struct to Access Specific Photo
struct CarImages: Codable {
    
    let largePhoto             :       String?
    
    enum CodingKeys: String, CodingKey {
        case largePhoto        =       "large"
    }
}
