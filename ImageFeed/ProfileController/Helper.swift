//  Helper.swift

import UIKit
import Kingfisher
import Foundation

class Helper: HelperProtocol{
    
    var logoutService: LogoutServiceProtocol?
    var imageStatus: ViewDownloadStatus = .someoneNoReady
    var labelsStatus: ViewDownloadStatus = .someoneNoReady
    weak var controller: ProfileViewControllerProtocol?
    
    func goToExit() {
        logoutService?.logout()
        let rootController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = rootController
    }
    
    func showOrHideShimmer(){
        if imageStatus == .imageIsReady && labelsStatus == .labelsIsReady {
            print("HERE")
            controller?.hideShimmer()
        } else {
            print(imageStatus, labelsStatus)
            controller?.showShimmer()
        }
    }
    
    init(logoutService: LogoutServiceProtocol? = nil, controller: ProfileViewControllerProtocol ) {
        self.logoutService = logoutService
        self.controller = controller
    }
    
}
