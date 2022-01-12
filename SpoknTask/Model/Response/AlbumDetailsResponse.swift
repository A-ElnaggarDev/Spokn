//
//  AlbumDetailsResponse.swift
//  SpoknTask
//
//  Created by maika on 10/01/2022.
//

import Foundation

struct AlbumDetailsResponse: Decodable {
    let id: Int
    let title: String
    let url: String
}
