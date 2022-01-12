//
//  ViewController.swift
//  SpoknTask
//
//  Created by maika on 09/01/2022.
//

import UIKit
import Combine
import SDWebImage

class AlbumDetailsVC: UIViewController, UISearchBarDelegate {


    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    private var Cancellable = Set<AnyCancellable>()
    
    private var albumDetailsArray = [AlbumDetailsResponse]()
    private var searchArrayResult = [AlbumDetailsResponse]()
    private var selectedShowArray = [AlbumDetailsResponse]()
    
    static var albumId: Int?
    var albumId2: String?
    var title2: String?
    static var title: String?
    var selectedImage: String!
    lazy var viewModel: AlbumDetailsViewModel = {
        return AlbumDetailsViewModel()
    }()
    
    lazy var profileVC = ProfileVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        initializeCollectionView()
        setNavigationBarView()
        initAlbumDetailsData()
        trackAPICallState()
        hideKeyboardWhenTappedAround()
    }
    
    //this function to set navigationbar title and make this title in large display mode
    private func setNavigationBarView() {
        self.navigationItem.title = AlbumDetailsVC.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    //this func responsable for filter images inside collection view based search bar text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            selectedShowArray = albumDetailsArray
            photosCollectionView.reloadData()
        } else {
            selectedShowArray = albumDetailsArray
                .filter{ $0.title.contains(searchText.lowercased())
            }
            photosCollectionView.reloadData()
        }
    }
    
    //this func used to make collection view show it's cell as a grid
    private func initializeCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.bounds.width / 3 , height: self.view.bounds.width / 3)
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        photosCollectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    
    //this func to fetch the data which will use inside collection view
    private func initAlbumDetailsData() {
        viewModel.fetchPhotosData(albumId: "\(AlbumDetailsVC.albumId!)")

        viewModel.$photosData.sink(receiveValue: { albumDetailsData in
            self.albumDetailsArray = albumDetailsData
            self.selectedShowArray = albumDetailsData
            self.photosCollectionView.reloadData()
        })
        .store(in: &Cancellable)
    }
    
    
    //this func used to track the api call and app take an action according to each state
    private func trackAPICallState() {
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

extension AlbumDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedShowArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumeDetailsCollectionViewCell
        cell.albumImage.sd_setImage(with: URL(string: selectedShowArray[indexPath.row].url))
        selectedImage = selectedShowArray[indexPath.row].url
        let menu = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(menu)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedImage = selectedShowArray[indexPath.row].url
    }
}


//MARK: this extension used when the user hold on the cell inside collection view to zoom photo in and show menu under this photo
extension AlbumDetailsVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu in
            
            //here you can add any number of action inside the menu
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { (_) in
                //here you can implement what you need to happen when user tap this action
                DispatchQueue.main.async {
                    self.sharingImplementation(imageUrl: [self.selectedImage])
                }
                
            }
            return UIMenu( children: [share])
        }
    }
    
    //this func call when user tap share button inside the menu which will appear when user hold on the cell inside coollection view
    private func sharingImplementation(imageUrl: [String]) {
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [imageUrl], applicationActivities: nil)
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

//hide keyboard when tap on screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
