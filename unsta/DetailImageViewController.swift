//
//  DetailImageViewController.swift
//  unsta
//
//  Created by Islam on 31.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//

import UIKit
import Sugar
import EasyPeasy

class DetailImageViewController: UIViewController {
    
    // MARK: Properties
    
    var imageUrl: String?
    
    lazy var imageView: UIImageView = {
        return UIImageView().then {
            $0.image = #imageLiteral(resourceName: "mountain")
            $0.contentMode = .scaleAspectFit
        }
    }()
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstriants()
        configureImage()
    }
    
    // MARK: Configure Views
    
    func configureViews() {
        view.addSubview(imageView)
    }
    
    // MARK: Configure Constraints
    
    func configureConstriants() {
        imageView <- [
            Size(UIScreen.main.bounds.width),
            Center()
        ]
    }
    
    // MARK: Load Image
    
    func configureImage() {
        guard let imageUrl = imageUrl else  { return }
        if let url = URL(string: imageUrl) {
            imageView.kf.setImage(with: url,
                                  placeholder: #imageLiteral(resourceName: "mountain"),
                                  options: [.transition(.fade(1))],
                                  progressBlock: nil,
                                  completionHandler: nil)
        }
    }
}
