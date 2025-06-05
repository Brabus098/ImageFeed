//
//  ShimerView.swift
//  ImageFeed
//
//  Created by Владимир on 04.06.2025.
//

import UIKit

final class ShimmerView: UIView {
    
    private let shimmerLayer = CAGradientLayer()
    private let animationKey = "shimmerAnimation"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureShimmer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureShimmer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
        shimmerLayer.cornerRadius = layer.cornerRadius
    }
    
    private func configureShimmer() {
        backgroundColor = .clear
        shimmerLayer.colors = [
            UIColor(white: 0.85, alpha: 1).cgColor,
            UIColor(white: 0.75, alpha: 1).cgColor,
            UIColor(white: 0.85, alpha: 1).cgColor
        ]
        shimmerLayer.locations = [0, 0.1, 0.3]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer.frame = bounds
        layer.addSublayer(shimmerLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.9, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: animationKey)
    }
    
    func stopShimmer() {
        shimmerLayer.removeAllAnimations()
        shimmerLayer.removeFromSuperlayer()
    }
}
