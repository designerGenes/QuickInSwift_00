//
//  CustomActivityIndicator.swift
//  CustomActivityIndicator
//
//  Created by Jaden Nation on 12/13/16.
//  Copyright © 2016 Jaden Nation. All rights reserved.
//

import UIKit

protocol ActivityIndicatorType {
	func startAnimating()
	func stopAnimating()
	var isAnimating: Bool { get set }
}


class CustomActivityIndicator: UIView, ActivityIndicatorType {
	// MARK: - properties
	private var numberOfBars: Int = 3
	var color: UIColor = UIColor.green
	var duration: Double = 0.35
	var maskLayers = [CAShapeLayer]()
	var isAnimating: Bool = false
	
	// MARK: - methods
	override func draw(_ rect: CGRect) {
		UIGraphicsGetCurrentContext()?.clear(rect)
		
		layer.backgroundColor = UIColor.clear.cgColor
		
		let individualWidth = frame.width / CGFloat(numberOfBars)
		for z in 0..<numberOfBars {
			let newLayer = CAShapeLayer()
			newLayer.anchorPoint = CGPoint(x: 0, y: 1)
			
				
			newLayer.path =	UIBezierPath(rect:
				CGRect(
					x: CGFloat(z) * individualWidth,
					y: 0,
					width: individualWidth - 0.5,
					height: frame.height)).cgPath

			
			newLayer.fillColor = color.cgColor
			layer.addSublayer(newLayer)
			
			let maskLayer = CAShapeLayer()
			maskLayer.path = UIBezierPath(roundedRect: CGRect(
					x: CGFloat(z) * individualWidth,
					y: 0,
					width: individualWidth - 1,
					height: frame.height * 2),
				  byRoundingCorners: [.topLeft, .topRight ],
				  cornerRadii: CGSize(width: 1 , height: 2)).cgPath
			
			maskLayer.anchorPoint = CGPoint(x: 0, y: 0)
			maskLayer.position = CGPoint(x: maskLayer.position.x, y: frame.height + 2)
			newLayer.mask = maskLayer
			maskLayers.append(maskLayer)
		}
	}
	

	func startAnimating() {
		isAnimating = true
		layer.opacity = 1  // implicit animation
		
		for (z, maskLayer) in maskLayers.enumerated() {
			var differential: CGFloat = 0
			if maskLayers.count > 2 {
				let middleIndex = Int(floor(Double(maskLayers.count) / 2))
				let fixedDelta = middleIndex - abs(middleIndex - z)
				differential += (frame.height * 0.15) * CGFloat(fixedDelta)
			}
			
			let motionAnimation = CABasicAnimation(keyPath: "position.y")
			motionAnimation.byValue = max(-frame.height, (-(frame.height / 2) - differential))
			
			let colorAnimation = CABasicAnimation(keyPath: "fillColor")
			
			colorAnimation.fromValue = color.withAlphaComponent(0.65).cgColor
			colorAnimation.toValue = color.cgColor
			
			
			for animation in [motionAnimation, colorAnimation] {
				animation.speed = 1 - (Float(z) * 0.1)
				animation.autoreverses = true
				animation.duration = duration
				animation.repeatCount = .infinity
				animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
			}
			
			maskLayer.add(colorAnimation, forKey: "fillColor")
			maskLayer.add(motionAnimation, forKey: "position.y")
			
		}
	}
	 
	
	func stopAnimating() {
		isAnimating = false
		layer.opacity = 0  // implicit animation
		for maskLayer in maskLayers {
			maskLayer.removeAllAnimations()
		}
	}
	
	convenience init(size: CGSize, withBars bars: Int, withDuration duration: Double, withColor color: UIColor) {
		self.init(frame: CGRect(origin: CGPoint.zero, size: size))
		numberOfBars = bars
		self.duration = duration
		self.color = color
		self.isOpaque = false
		layer.opacity = 0
	}
	

}
