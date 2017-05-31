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

class MainViewController: UIViewController {
    
    // MARK: View Properties
    
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
    
    func filterContentForSearchText(searchText: String) {
         view.endEditing(true)
         print(searchText)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MainCollectionViewCell
        return cell
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
        guard let text = searchBar.text else { return }
        filterContentForSearchText(searchText: text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
}
