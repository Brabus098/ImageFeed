//  MockHelper.swift
import XCTest
import Foundation

@testable import ImageFeed

// Мок для HelperProtocol
class MockHelper: HelperProtocol {
    var logoutService: LogoutServiceProtocol?
    var imageStatus: ViewDownloadStatus = .someoneNoReady
    var labelsStatus: ViewDownloadStatus = .someoneNoReady
    var controller: ProfileViewControllerProtocol?
    var showOrHideShimmerCalled = false
    var goToExitCalled = false
    
    func showOrHideShimmer() {
        showOrHideShimmerCalled = true
    }
    
    func goToExit() {
        goToExitCalled = true
    }
}
