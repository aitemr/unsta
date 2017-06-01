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
import SVProgressHUD
import DZNEmptyDataSet

class MainViewController: UIViewController {
    
    // MARK: View Properties
    
    var images: [Image] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let options = [
        PeekViewAction(title: "Save", style: .default),
        PeekViewAction(title: "Share", style: .default),
        PeekViewAction(title: "Cancel", style: .destructive)
    ]
    
    var forceTouchAvailable = false
    
    fileprivate lazy var searchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.delegate = self
        searchbar.placeholder = "username"
        searchbar.autocapitalizationType = .none
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
        collectionView.emptyDataSetSource = self
        collectionView.emptyDataSetDelegate = self
        return collectionView
    }()
    
    lazy var searchBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.target = self
        button.action = #selector(showSearchBar)
        button.image = #imageLiteral(resourceName: "srch")
        return button
    }()
    
    lazy var settingsBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.target = self
        button.action = #selector(settingsButtonDidPress)
        button.image = #imageLiteral(resourceName: "settings")
        return button
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
        title = "unsta.me"
        navigationItem.leftBarButtonItem = settingsBarButton
        navigationItem.rightBarButtonItem = searchBarButton
        navigationController?.navigationBar.tintColor = .black
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
    
    func fetchImageBy(username: String) {
        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        if !username.isEmpty {
            Image.fetchImageBy(username: username, completion: { (result, error, code) in
                if error == nil {
                    guard let code = code else { return }
                    switch code {
                    case 0:
                        guard let result = result else { return }
                        !result.isEmpty ? self.images = result
                                        : Drop.down("\(username) doesn't have images :(")
                        SVProgressHUD.dismiss()
                    case 1...3:
                        Drop.down("This username doesn't exist")
                        SVProgressHUD.dismiss()
                    case 4:
                        Drop.down("You will be notified when \(username) will be unlocked")
                        SVProgressHUD.dismiss()
                    default:
                        SVProgressHUD.dismiss()
                    }
                }
            })
        }
    }
    
    // MARK: User Interaction

    func saved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            Drop.down(error.localizedDescription, state: .error)
        } else {
            Drop.down("Image has been saved to your photos.", state: .success)
        }
    }

    func longPressCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let cell = gestureRecognizer.view as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            let image = images[(indexPath as NSIndexPath).item]
            let controller = DetailImageViewController()
            controller.imageUrl = image.url
            let frame = CGRect(x: 15, y: (UIScreen.main.bounds.height - 300)/2, width: UIScreen.main.bounds.width - 30, height: 300)
            PeekView().viewForController(parentViewController: self, contentViewController: controller, expectedContentViewFrame: frame, fromGesture: gestureRecognizer, shouldHideStatusBar: true, menuOptions: options, completionHandler: { optionIndex in
                switch optionIndex {
                case 0:
                    guard let url = image.url?.url else { break }
                    KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { kfimage, error, cacheType, url in
                        if let kfimage = kfimage {
                            UIImageWriteToSavedPhotosAlbum(kfimage, self,
                                                           #selector(self.saved(_:didFinishSavingWithError:contextInfo:)), nil)
                        } else {
                            Drop.down("Check your internet connection", state: .error)
                        }
                    })
                case 1:
                    print("Option 2 selected")
                default:
                    break
                }
            }, dismissHandler: nil)
        }
    }
    
    func showSearchBar() {
        searchbar.isHidden = false
        searchbar.showsCancelButton = true
        searchbar.placeholder = "username"
        let uiButton = searchbar.value(forKey: "cancelButton") as! UIButton
        uiButton.setTitle("Cancel", for: UIControlState.normal)
        self.navigationItem.titleView = searchbar
        self.navigationItem.rightBarButtonItem = nil
        searchbar.becomeFirstResponder()
    }
    
    @objc fileprivate func settingsButtonDidPress() {
        let _ = navigationController?.pushViewController(SettingsViewController(), animated: true)
    }
    
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MainCollectionViewCell
        if let imageUrl = images[indexPath.item].url {
            if let url = URL(string: imageUrl) {
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
            gesture.minimumPressDuration = 0.1
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
        searchBar.isHidden = true
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = searchBarButton
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let username = searchBar.text else { return }
        fetchImageBy(username: username)
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
        
        let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view))
        if let indexPath = indexPath {
            let url = images[(indexPath as NSIndexPath).item].url
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

extension MainViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "search")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let myString = "Search private Instagram account"
        let myAttribute = [ NSForegroundColorAttributeName: UIColor.black ]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        return myAttrString
    }
    
//    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
//        let myString = "Эта функция будет доступна в будущих версиях"
//        let myAttribute = [ NSForegroundColorAttributeName: UIColor.black ]
//        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
//        return myAttrString
//    }
}

