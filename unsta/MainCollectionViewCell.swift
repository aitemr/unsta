//
//  MainCollectionViewCell.swift
//  unsta
//
//  Created by Islam on 30.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//

import UIKit
import Reusable
import Sugar
import EasyPeasy

class MainCollectionViewCell: UICollectionViewCell, Reusable {
    
    // MARK: Properties
    
    lazy var imageView: UIImageView = {
        return UIImageView().then {
            $0.image = #imageLiteral(resourceName: "mountain")
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
    }()
    
    // MARK: View LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstriants()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure Views
    
    func configureViews() {
        self.addSubview(imageView)
    }
    
    // MARK: Configure Constraints
    
    func configureConstriants() {
        imageView <- [
            Edges(0)
        ]
    }
}
