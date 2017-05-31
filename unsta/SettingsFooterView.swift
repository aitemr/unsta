//
//  SettingsFooterView.swift
//  CodeLab
//
//  Created by Islam on 02.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//
import UIKit
import EasyPeasy

final class SettingsFooterView: UIView {

    // MARK: Properties

    fileprivate lazy var madeWithLabel: UILabel = {
        return  UILabel().then {
            $0.text = "Made with"
        }
    }()

    fileprivate lazy var heartImageView: UIImageView = {
        return UIImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = #imageLiteral(resourceName: "heart")
        }
    }()

    fileprivate lazy var inLabel: UILabel = {
        return  UILabel().then {
            $0.text = "in"
        }
    }()

    fileprivate lazy var almatyLabel: UILabel = {
        return  UILabel().then {
            $0.text = "Almaty"
        }
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstriants()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector:
            #selector(SettingsFooterView.animateHeart), userInfo: nil, repeats: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configure Views

    func configureViews() {
        [madeWithLabel, heartImageView, inLabel, almatyLabel].forEach {
            self.addSubview($0)
        }
        [madeWithLabel, inLabel, almatyLabel].forEach {
            $0.alpha = 0.7
        }
    }

    // MARK: Animations

    func animateHeart(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
            self.heartImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.heartImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.heartImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }

    // MARK: Configure Constraints

    func configureConstriants() {
        heartImageView <- [
            Center(0),
            Size(15)
        ]

        madeWithLabel <- [
            CenterY(),
            Right(5).to(heartImageView, .left)
        ]

        inLabel <- [
            CenterY(),
            Left(5).to(heartImageView, .right)
        ]
        almatyLabel <- [
            CenterY(),
            Left(5).to(inLabel, .right)
        ]
    }
}
