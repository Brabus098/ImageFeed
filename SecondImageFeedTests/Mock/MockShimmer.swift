//  MockShimmer.swift

import XCTest
import Foundation

@testable import ImageFeed

// Мок для ShimmerProtocol
class MockShimmer: ShimmerProtocol {
    var showShimmerCalled = false
    var cleanLayersCalled = false
    var views: [UIView] = []
    var animationLayers = Set<CALayer>()
    
    
    func showShimmer(over view: UIView) {
        showShimmerCalled = true
        views.append(view)
        animationLayers.insert(CALayer())
    }
    
    func cleanLayers() {
        cleanLayersCalled = true
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
