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
        
    }
    
    // MARK: Configure Constraints
    
    func configureConstriants() {
        
    }
}
