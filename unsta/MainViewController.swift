//
//  ViewController.swift
//  unsta
//
//  Created by Islam on 30.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//

import UIKit
import Sugar
import EasyPeasy
import Kingfisher
import PeekView

class MainViewController: UIViewController {
    
    // MARK: View Properties
    
    var photos: [Photo] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var forceTouchAvailable = false
    
    fileprivate lazy var searchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.delegate = self
        searchbar.placeholder = "yuframe"
        return searchbar
    }()
    
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width / 3 - 1, height: self.view.frame.width / 3 - 1)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        return layout
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.register(cellType: MainCollectionViewCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forceTouchAvailable = false
        configureNavBar()
        configureViews()
        configureConstriants()
    }
    
    // MARK: Configure Navigation Bar
    
    func configureNavBar() {
        navigationItem.titleView = searchbar
        searchbar.tintColor = .black
        definesPresentationContext = true
    }
    
    // MARK: Configure Views
    
    func configureViews() {
        view.addSubview(collectionView)
    }
    
    // MARK: Configure Constraints
    
    func configureConstriants() {
        collectionView <- [
            Edges(0)
        ]
    }
    
    // MARK: Fetch Data

    func fetchPhotoBy(username: String) {
        if !username.isEmpty {
            Photo.fetchPhotoBy(username: username, completion: { (result, error) in
                if error == nil {
                    guard let result = result else { return }
                    self.photos = result
                }
            })
        }
    }
    
    func longPressCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if let cell = gestureRecognizer.view as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            let url = photos[(indexPath as NSIndexPath).item].url
            let controller = DetailImageViewController()
            controller.imageUrl = url
            let frame = CGRect(x: 15, y: (UIScreen.main.bounds.height - 300)/2, width: UIScreen.main.bounds.width - 30, height: 300)
            
            let options = [
                PeekViewAction(title: "Save", style: .default),
                PeekViewAction(title: "Share", style: .default),
                PeekViewAction(title: "Cancel", style: .destructive)
            ]
            PeekView().viewForController(parentViewController: self, contentViewController: controller, expectedContentViewFrame: frame, fromGesture: gestureRecognizer, shouldHideStatusBar: true, menuOptions: options, completionHandler: { optionIndex in
                switch optionIndex {
                case 0:
                    print("Option 1 selected")
                case 1:
                    print("Option 2 selected")
                case 2:
                    print("Option 3 selected")
                default:
                    break
                }
            }, dismissHandler: {
                print("Peekview dismissed!")
            })
        }
    }
    
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MainCollectionViewCell
        if let photoUrl = photos[indexPath.item].url {
            if let url = URL(string: photoUrl) {
                cell.imageView.kf.setImage(with: url,
                                           placeholder: #imageLiteral(resourceName: "mountain"),
                                           options: [.transition(.fade(1))],
                                           progressBlock: nil,
                                           completionHandler: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if forceTouchAvailable == false {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressCell(_:)))
            gesture.minimumPressDuration = 0.5
            cell.addGestureRecognizer(gesture)
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let username = searchBar.text else { return }
        fetchPhotoBy(username: username)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}

extension MainViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard #available(iOS 9.0, *) else {
            return nil
        }
        
        let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from:view))
        if let indexPath = indexPath {
            let url = photos[(indexPath as NSIndexPath).item].url
            if let cell = collectionView.cellForItem(at: indexPath) {
                previewingContext.sourceRect = cell.frame
                let controller = DetailImageViewController()
                controller.imageUrl = url
                return controller
            }
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let controller = DetailImageViewController()
        controller.imageUrl = (viewControllerToCommit as! DetailImageViewController).imageUrl
        navigationController?.pushViewController(controller, animated: true)
    }
}
