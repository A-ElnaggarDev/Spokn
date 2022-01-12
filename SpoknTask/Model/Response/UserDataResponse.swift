//
//  UserDataResponse.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import Foundation


struct UserDataResponse: Decodable {
    let id: Int
    let name: String
    let address: UserAddressData
}

struct UserAddressData: Decodable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
}
