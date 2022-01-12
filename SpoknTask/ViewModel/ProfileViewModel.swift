//
//  ProfileViewModel.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import Foundation
import Combine

class ProfileViewModel {
    
    @Published var userData = [UserDataResponse]()
    @Published var userAlbums = [UserAlbumsResponse]()
    @Published var state: State = .empty
    
    var errorMessage: String = ""
    private var Cancellable = Set<AnyCancellable>()
    
    
    //this func fetch user data like user, userName and address...etc
    func fetchUserData() {
        state = .loading
        ClientService.shared.fetchUserData()
            .receive(on: RunLoop.main)
            .map{ $0 }
            .sink { (completion) in
                
                switch completion {
                
                    case .finished:
                        self.state = .populated
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.state = .error
                }
            } receiveValue: { [weak self] user in
                guard let self = self else {return}
                self.userData = user
            }
            .store(in: &Cancellable)
    }
    

    //this func to fetch all ablums of user here you will find the power of flatMap in combine to act with async calls
    func fetchUserAlbums() {
        state = .loading
        ClientService.shared.fetchUserData()
            .receive(on: RunLoop.main)
            .map{ $0 }
            .flatMap{ userData in
                return ClientService.shared.fetchUserAlbumsData(userId: "\(userData[0].id)")
            }
            .sink { (completion) in
                
                switch completion {
                
                case .finished:
                    self.state = .populated
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.state = .error
                }
            } receiveValue: {[weak self] albums in
                guard let self = self else {return}
                self.userAlbums = albums
            }
            .store(in: &Cancellable)
    }
}
