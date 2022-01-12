//
//  AlbumDetailsViewModel.swift
//  SpoknTask
//
//  Created by maika on 10/01/2022.
//

import Foundation
import Combine

class AlbumDetailsViewModel {
    
    @Published var photosData = [AlbumDetailsResponse]()
    @Published var state: State = .empty
    
    var errorMessage: String = ""
    
    private var Cancellable = Set<AnyCancellable>()

    //this func fetch album details like album id , photos inside this album
    func fetchPhotosData(albumId: String) {
        state = .loading
        ClientService.shared.fetchAlbumDetailsData(albumId: albumId)
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
            } receiveValue: {[weak self] photos in
                guard let self = self else {return}
                self.photosData = photos
            }
            .store(in: &Cancellable)
    }
}
