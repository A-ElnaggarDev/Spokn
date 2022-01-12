//
//  ClientService.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import Foundation
import Combine

final class ClientService {
    
    static let shared = ClientService()
    
    private init() {}
    
    private var dispatchGroup = DispatchGroup()
    var AnyCancellable = Set<AnyCancellable>()
    
    enum Endpoints {
        static let base = "https://jsonplaceholder.typicode.com/"
        
        //add any endpoint here you want
        case userData(String)
        case userAlbums(String)
        case albumDetails(String)
        
        //here you concatenate your api url as string
        var stringValue: String {
            switch self {
            case .userData(let userId):
                return Endpoints.base + "users?id=" + userId
                
            case .userAlbums(let userId):
                return Endpoints.base + "albums?userId=" + userId
                
            case .albumDetails(let albumId):
                return Endpoints.base + "photos?albumId=" + albumId
            }
        }
        
        //here transform string to url
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // this function retrieve user data like userId, userName and address...etc which shown at the top of profileVC and we use it with profile module
    func fetchUserData() -> AnyPublisher<[UserDataResponse], Error> {
        return URLSession.shared.dataTaskPublisher(for: Endpoints.userData("1").url)
            .map { $0.data }
            .decode(type: [UserDataResponse].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // this function retrieve data of user albums which shown in albums table view inside profileVC and we use it with profile module
    func fetchUserAlbumsData(userId: String) -> AnyPublisher<[UserAlbumsResponse], Error> {
        return URLSession.shared.dataTaskPublisher(for: Endpoints.userAlbums(userId).url)
            .map{$0.data}
            .decode(type: [UserAlbumsResponse].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    // this function retrieve data insid  albums which shown in photo collection view inside albumDetailsVC and we use it with album detrails module
    func fetchAlbumDetailsData(albumId: String) -> AnyPublisher<[AlbumDetailsResponse], Error> {
        return URLSession.shared.dataTaskPublisher(for: Endpoints.albumDetails(albumId).url)
            .map { $0.data }
            .decode(type: [AlbumDetailsResponse].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
}
