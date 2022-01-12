//
//  UserAlbumsResponse.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import Foundation


struct UserAlbumsResponse: Decodable {
    let userId: Int
    let id: Int
    let title: String
}
