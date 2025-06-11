//  ControllerProtocols.swift

import UIKit
import Kingfisher
import Foundation

protocol ProfileViewControllerProtocol {
    var profileService: ProfileServiceProtocol? { get set }
    var helper: HelperProtocol? { get set }
    func showShimmer()
    func hideShimmer()
    func confirmExit()
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

protocol HelperProtocol{
    var controller: ProfileViewControllerProtocol? { get set }
    var imageStatus: ViewDownloadStatus { get set }
    var labelsStatus: ViewDownloadStatus { get set }
    func showOrHideShimmer()
    func goToExit()
    var logoutService: LogoutServiceProtocol? { get set }
}

enum ViewDownloadStatus {
    case imageIsReady
    case labelsIsReady
    case someoneNoReady
}

protocol LogoutServiceProtocol {
    func logout()
}

protocol ShimmerProtocol {
    func showShimmer(over view: UIView)
    func cleanLayers()
    var animationLayers: Set<CALayer> { get set}
}
