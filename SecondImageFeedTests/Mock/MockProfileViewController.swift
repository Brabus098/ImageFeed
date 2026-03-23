//  MockProfileViewController.swift

import XCTest
import Foundation

@testable import ImageFeed


// Мок для ProfileViewControllerProtocol
class MockProfileViewController: ProfileViewControllerProtocol {
    var profileService: ProfileServiceProtocol?
    var helper: HelperProtocol?
    var showShimmerCalled = false
    var hideShimmerCalled = false
    
    func showShimmer() {
        showShimmerCalled = true
    }
    
    func hideShimmer() {
        hideShimmerCalled = true
    }
    func confirmExit() {
        helper?.goToExit()
    }
}
