//  Shimmer.swift
import UIKit
import Kingfisher
import Foundation

final class Shimmer: ShimmerProtocol {
    
    var animationLayers = Set<CALayer>()
    
    func showShimmer(over view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.frame.height / 2
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        animationLayers.insert(gradient)
        view.layer.addSublayer(gradient)
    }
    
    func cleanLayers() {
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
