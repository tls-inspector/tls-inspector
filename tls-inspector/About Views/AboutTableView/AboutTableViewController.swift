// TLS Inspector
// Copyright (C) Ian Spence and other TLS Inspector Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import StoreKit
import TLSKit
import Localization

class AboutTableView: UITableView, UITableViewDataSource, UITableViewDelegate, @preconcurrency SKStoreProductViewControllerDelegate {
    private let dnsInspectorAppId = 6470965982
    private let dnsInspectorAppStoreCampaignId = "crash-override"
    private let tlsInspectorAppId = 1100539810
    private let tlsInspectorAppStoreCampaignId = "crash-override"
    private let projectURL = URL(string: "https://tlsinspector.com/")!
    private let projectContributeURL = URL(string: "https://tlsinspector.com/github")!
    private let mastodonURL = URL(string: "https://infosec.exchange/@tlsinspector")!
    private let blueskyURL = URL(string: "https://bsky.app/profile/tlsinspector.com")!
    private let rows: [[UITableViewCell]]
    private let sectionHeaders: [String?]
    private let sectionFooters: [String?]

    override init(frame: CGRect, style: UITableView.Style) {
        self.rows = [
            [
                AboutTableView.iconCell(text: Localize.sharetlsinspector(), image: UIImage(systemName: "square.and.arrow.up")!, reuseIdentifier: "share"),
                AboutTableView.iconCell(text: Localize.rateinappstore(), image: UIImage(systemName: "star.fill")!, reuseIdentifier: "rate"),
            ],
            [
                AboutTableView.iconCell(text: Localize.followusonmastodon(), image: UIImage(resource: .mastodon), reuseIdentifier: "mastodon"),
                AboutTableView.iconCell(text: Localize.followusonbluesky(), image: UIImage(resource: .bluesky), reuseIdentifier: "bluesky"),
            ],
            [
                AboutTableView.iconCell(text: Localize.contributetotlsinspector(), image: UIImage(systemName: "apple.terminal")!, reuseIdentifier: "contribute"),
                AboutTableView.iconCell(text: Localize.opensourcelicensesattributions(), image: UIImage(systemName: "heart.fill")!, reuseIdentifier: "oss"),
            ],
            [
                AboutTableView.iconCell(text: "DNS Inspector", image: UIImage(resource: .dnsInspector), reuseIdentifier: "dnsi"),
            ],
            []
        ]
        self.sectionHeaders = [
            Localize.sharefeedback(),
            Localize.followus(),
            Localize.getinvolved(),
            Localize.morefromthedeveloper(),
            nil,
        ]
        self.sectionFooters = [
            Localize.appversionbuildopensslversioncurlversion(version: EnvironmentInfo.version(), build: EnvironmentInfo.build(), opensslversion: Versions.openssl.string, curlversion: Versions.curl.string),
            nil,
            nil,
            Localize.licensefooter(),
            "🏳️‍⚧️ Trans Rights!"
        ]
        super.init(frame: frame, style: .insetGrouped)
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - Conveience Methods

    private static func iconCell(text: String, image: UIImage, reuseIdentifier: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.text = text
        cell.imageView?.image = image
        cell.imageView?.contentMode = .scaleAspectFit
        return cell
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        // Since this isn't a view controller but rather just a table view - we have to find the view controller that's hosting this view
        // I have no idea if there's a better way of doing this
        self.window?.rootViewController?.presentedViewController?.present(viewController, animated: true)
    }

    required init?(coder: NSCoder) {
        self.rows = []
        self.sectionHeaders = []
        self.sectionFooters = []
        super.init(coder: coder)
    }

    // MARK: - Table View Methods

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section]
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sectionFooters[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.rows[indexPath.section][indexPath.row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows[section].count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.rows[indexPath.section][indexPath.row]
        switch cell.reuseIdentifier {
        case "share":
            break
        case "rate":
            self.showProductInAppStore(tlsInspectorAppId, campaignId: tlsInspectorAppStoreCampaignId)
        case "mastodon":
            UIApplication.shared.open(mastodonURL)
        case "bluesky":
            UIApplication.shared.open(blueskyURL)
        case "contribute":
            UIApplication.shared.open(projectContributeURL)
        case "foss":
            break
        case "dnsi":
            self.showProductInAppStore(dnsInspectorAppId, campaignId: dnsInspectorAppStoreCampaignId)
        default:
            break
        }

        self.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Store Methods

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }

    func showProductInAppStore(_ productId: Int, campaignId: String) {
        let productViewController = SKStoreProductViewController()
        productViewController.delegate = self
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: "\(productId)",
            SKStoreProductParameterCampaignToken: campaignId,
        ]
        productViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        self.present(productViewController, animated: true)
    }
}
