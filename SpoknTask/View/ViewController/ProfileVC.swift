//
//  ProfileVC.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import UIKit
import Combine


protocol selectedAlbumDelegate {
    func didTapChoise(albumId: String, albumTitle: String)
}

class ProfileVC: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userAddressLbl: UILabel!
    @IBOutlet weak var albumsTableView: UITableView!
    
    
    private var Cancellable = Set<AnyCancellable>()
    private var userAlbumsArray = [UserAlbumsResponse]()

    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarView()
        fetchUserData()
        initUserAlbums()
        trackAPICallsState()
    }
    
    //this function to set navigationbar title and make this title in large display mode
    private func setNavigationBarView() {
        self.navigationItem.title = "Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    //this func to retrieve user data like user name and adress show in the top of the screen
    private func fetchUserData() {
        indicator.startAnimating()
        viewModel.fetchUserData()
        viewModel.$userData.sink { [weak self] userData in
            guard let self = self else { return }
            if userData.count > 0 {
                self.indicator.stopAnimating()
                self.userNameLbl.text = userData[0].name
                self.userAddressLbl.text = userData[0].address.street + " " + userData[0].address.city + " " + userData[0].address.suite + " " + userData[0].address.zipcode
            }
        }
        .store(in: &Cancellable)
    }
    
    //this func to retrieve user albums show in table view
    private func initUserAlbums() {
        viewModel.fetchUserAlbums()
        
        viewModel.$userAlbums.sink { [weak self] albums in
            guard let self = self else { return }
            self.userAlbumsArray = albums
            self.albumsTableView.reloadData()
        }
        .store(in: &Cancellable)
    }
    
    //this func used to track the api call and app take an action according to each state
    private func trackAPICallsState() {
        viewModel.$state.sink { state in
            switch state {
            case .error:
                self.showAlert(message: self.viewModel.errorMessage)
                self.indicator.stopAnimating()
                
            case .empty:
                print("state is empty")
                
            case .loading:
                self.indicator.startAnimating()
                
            case .populated:
                self.indicator.stopAnimating()
            }
        }
        .store(in: &Cancellable)
    }
    
    //call this func when you want to show alert for error on the screen
     private func showAlert(message: String) {
            let alertVC = UIAlertController(title: "error", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
    }
}


extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAlbumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = userAlbumsArray[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Albums"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        AlbumDetailsVC.albumId = userAlbumsArray[indexPath.row].id
        AlbumDetailsVC.title = userAlbumsArray[indexPath.row].title
        
        let albumDetailsVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "albumsdetailsVC")
        navigationController?.pushViewController(albumDetailsVC, animated: true)
    }
}

