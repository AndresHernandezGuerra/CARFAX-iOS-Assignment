//
//  DealerDetailedInfo.swift
//  CARFAX iOS Assignment
//
//  Created by Andres S. Hernandez G. on 8/18/19.
//  Copyright © 2019 Andres S. Hernandez G. All rights reserved.
//

import Foundation

// MARK: - Dealer Properties
struct DealerDetails: Codable {
    
    let name                    :       String?
    let address                 :       String?
    let city                    :       String?
    let state                   :       String?
    let zip                     :       String?
    let phone                   :       String?
    
    enum CodingKeys: String, CodingKey {
        case phone              =       "phone"
        case name               =       "name"
        case address            =       "address"
        case city               =       "city"
        case state              =       "state"
        case zip                =       "zip"
    }
}
