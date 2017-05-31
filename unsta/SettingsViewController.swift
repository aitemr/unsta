//
//  SettingsViewController.swift
//  CodeLab
//
//  Created by Islam on 02.05.17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//
import UIKit
import EasyPeasy
import MessageUI
import Reusable

struct SettingsCellItem {
    var title: String?
    var icon: UIImage?
}

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    // MARK: View Properties

    fileprivate lazy var tableView: UITableView = {
        return UITableView(frame: .zero, style: .grouped).then {
            $0.register(cellType: SettingsTableViewCell.self)
            $0.register(cellType: NotificationsTableViewCell.self)
            $0.dataSource = self
            $0.delegate = self
            $0.rowHeight = 44
            $0.tableFooterView = SettingsFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25))
        }
    }()

    fileprivate lazy var cellItems = [
        [],
        [SettingsCellItem(title: "Notifications", icon: #imageLiteral(resourceName: "notification"))],
        [SettingsCellItem(title: "Share", icon: #imageLiteral(resourceName: "share")),
         SettingsCellItem(title: "Rate 5 stars", icon: #imageLiteral(resourceName: "rate")),
         SettingsCellItem(title: "Leave a Feedback", icon: #imageLiteral(resourceName: "mail"))
        ]
    ]

    // MARK: View lifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureViews()
        configureConstriants()
    }

    // MARK: Configure Views

    func configureViews() {
        view.backgroundColor = .green
        view.addSubview(tableView)
    }

    // MARK: Configure Constraints

    func configureConstriants() {
        tableView <- [
            Top(0),
            Bottom(0),
            Left(0),
            Right(0)
        ]
    }

    // MARK: - Setup Navigation bar button

    func configureNavBar() {
        title = "Settings"
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 9/255, green: 9/255, blue: 26/255, alpha: 1)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close"), style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
    }

    // MARK: User Interactions

    @objc fileprivate func closeButtonPressed(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }

    @objc fileprivate func rate() {
        guard let url = URL(string : Constant.reviewUrl) else { return }
        guard #available(iOS 10, *) else {
            UIApplication.shared.openURL(url)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc fileprivate func feedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    @objc fileprivate func share() {
        if let itunesUrl = URL(string: Constant.appUrl) {
            let objectsToShare = [Constant.appName, itunesUrl] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = UIView()
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([Constant.companyMail])
        mailComposerVC.setSubject(Constant.appName)
        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            actionSheetController.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }

    // MARK: MFMailComposeViewControllerDelegate Method

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return cellItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = cellItems[indexPath.section][indexPath.row]
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(for: indexPath) as NotificationsTableViewCell
            cell.setUpWithTitle(item.title, sectionIcon: item.icon)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(for: indexPath) as SettingsTableViewCell
            cell.setUpWithTitle(item.title, sectionIcon: item.icon)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (2, 0): share()
        case (2, 1): rate()
        case (2, 2): feedback()
        default: rate()
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "General"
        case 1: return "Support Us"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 5
    }
}
