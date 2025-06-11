//  MockLogoutService.swift

import XCTest
import Foundation

@testable import ImageFeed

class MockLogoutService: LogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
