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
import Permission
import Tactile

class NotificationsTableViewCell: UITableViewCell, Reusable {

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

    fileprivate lazy var tumblerSwitch: UISwitch = {
        let t = UISwitch()
        t.onTintColor = #colorLiteral(red: 1, green: 0.1490196078, blue: 0.2745098039, alpha: 1)

        return t
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
        [sectionImageView, titleLabel, tumblerSwitch].forEach {
            contentView.addSubview($0)
        }
    }

    fileprivate func configureNotification(permission: Permission, switcher: UISwitch) {
        switcher.setOn(permission.status == .authorized, animated: false)
        switcher.on(.valueChanged) { _ in
            if !switcher.isOn {
                Drop.down("You can disable it through your phone Settings", state: .error)
                switcher.setOn(permission.status == .authorized, animated: false)
            } else {
                permission.request({ status in
                    switcher.setOn(status == .authorized, animated: true)
                    if status != .authorized { Drop.down("You can enable it through your phone Settings", state: .error) }
                })
            }
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

        tumblerSwitch <- [
            CenterY(),
            Right(10)
        ]
    }
}

extension NotificationsTableViewCell {
    func setUpWithTitle(_ sectionTitle: String?, sectionIcon: UIImage?) {
        titleLabel.text = sectionTitle
        sectionImageView.image = sectionIcon
        configureNotification(permission: Permission.notifications, switcher: tumblerSwitch)
    }
}
