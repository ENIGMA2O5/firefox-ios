// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import XCTest
@testable import Client
import Shared
import Storage
import SyncTelemetry

class TopSitesViewModelTests: XCTestCase {
    var profile: MockProfile!

    override func setUp() {
        super.setUp()
        self.profile = MockProfile(databasePrefix: "FxHomeTopSitesViewModelTests")

        FeatureFlagsManager.shared.initializeDeveloperFeatures(with: profile)
    }

    override func tearDown() {
        super.tearDown()
        self.profile._shutdown()
        self.profile = nil
    }

    func testDeletionOfSingleSuggestedSite() {
        let viewModel = TopSitesViewModel(profile: profile,
                                          isZeroSearch: false)
        let topSitesProvider = TopSitesProviderImplementation(browserHistoryFetcher: profile.history,
                                                              prefs: profile.prefs)

        let siteToDelete = topSitesProvider.defaultTopSites(profile.prefs)[0]

        viewModel.hideURLFromTopSites(siteToDelete)
        let newSites = topSitesProvider.defaultTopSites(profile.prefs)

        XCTAssertFalse(newSites.contains(siteToDelete, f: { (a, b) -> Bool in
            return a.url == b.url
        }))
    }

    func testDeletionOfAllDefaultSites() {
        let viewModel = TopSitesViewModel(profile: self.profile,
                                          isZeroSearch: false)
        let topSitesProvider = TopSitesProviderImplementation(browserHistoryFetcher: profile.history,
                                                              prefs: profile.prefs)

        let defaultSites = topSitesProvider.defaultTopSites(profile.prefs)
        defaultSites.forEach({
            viewModel.hideURLFromTopSites($0)
        })

        let newSites = topSitesProvider.defaultTopSites(profile.prefs)
        XCTAssertTrue(newSites.isEmpty)
    }
}

// MARK: Helper methods
extension TopSitesViewModelTests {

    func createViewModel(overridenSiteCount: Int = 40, overridenNumberOfRows: Int = 2) -> TopSitesViewModel {
        let viewModel = TopSitesViewModel(profile: self.profile,
                                          isZeroSearch: false)
        trackForMemoryLeaks(viewModel)

        return viewModel
    }
}
