//
//  SettingsTableViewCell.swift
//  CodeLab
//
//  Created by Islam on 02.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//
import UIKit
import Sugar
import EasyPeasy
import Reusable

class SettingsTableViewCell: UITableViewCell, Reusable {

    fileprivate lazy var titleLabel: UILabel = {
        return  UILabel().then {
            $0.font = .systemFont(ofSize: 15)
        }
    }()

    fileprivate lazy var sectionImageView: UIImageView = {
        return UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 3
        }
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstriants()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configure Views

    func configureViews() {
        separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        [sectionImageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: Configure Constraints

    func configureConstriants() {
        sectionImageView <- [
            CenterY(),
            Left(10),
            Size(25)
        ]

        titleLabel <- [
            CenterY(),
            Left(10).to(sectionImageView, .right)
        ]
    }
}

extension SettingsTableViewCell {
    func setUpWithTitle(_ sectionTitle: String?, sectionIcon: UIImage?) {
        titleLabel.text = sectionTitle
        sectionImageView.image = sectionIcon
    }
}
