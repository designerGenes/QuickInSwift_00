import UIKit

protocol ActivityIndicatorType {
	func startAnimating()
	func stopAnimating()
	var isAnimating: Bool { get set }
}


class CustomActivityIndicator: UIView, ActivityIndicatorType {
	// MARK: - properties
	private var numberOfBars: Int = 3
	private var frameView = UIView()
	var color: UIColor = UIColor.white
	var duration: Double = 0.35
	var maskLayers = [CAShapeLayer]()
	var dropLayers = [CAShapeLayer]()
	var isAnimating: Bool = false
	
	// MARK: - methods
	override func draw(_ rect: CGRect) {
		UIGraphicsGetCurrentContext()?.clear(rect) // removes solid black rectangle in rect
		layer.backgroundColor = UIColor.clear.cgColor
		
		addSubview(frameView)
		frameView.frame = rect
		frameView.layer.cornerRadius = 2
		frameView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		
		let individualWidth = frame.width / CGFloat(numberOfBars)
		for z in 0..<numberOfBars {
			let newLayer = CAShapeLayer()
			newLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
			newLayer.path =	UIBezierPath(rect:
				CGRect(
					x: CGFloat(z) * individualWidth,
					y: 0,
					width: individualWidth,
					height: frame.height)).cgPath
			newLayer.fillColor = color.cgColor
			layer.addSublayer(newLayer)
			
			// animates bars going up and down
			let maskLayer = CAShapeLayer()
			maskLayer.path = UIBezierPath(roundedRect: CGRect(
					x: CGFloat(z) * individualWidth,
					y: 0,
					width: individualWidth,
					height: frame.height * 2),
				  byRoundingCorners: [.topLeft, .topRight ],
				  cornerRadii: CGSize(width: 1 , height: 2)).cgPath
			maskLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			maskLayer.position = CGPoint(x: maskLayer.position.x, y: frame.height + 2)
			newLayer.mask = maskLayer
			maskLayers.append(maskLayer)
			
			// animates skinny bars which drop slowly after main bars snap upwards
			let dropLayer = CAShapeLayer()
			dropLayer.frame = CGRect(
				x: CGFloat(z) * individualWidth,
				y: frame.height + 2,
				width: individualWidth,
				height: 1)
			dropLayer.fillColor = color.cgColor
			dropLayer.backgroundColor = color.cgColor
			dropLayers.append(dropLayer)
			layer.addSublayer(dropLayer)
			layer.masksToBounds = true
		
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
				differential += (frame.height * 0.22) * CGFloat(fixedDelta)
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
			
			
			let dropAnimation = CABasicAnimation(keyPath: "position.y")
			dropAnimation.fromValue = (frame.height / 2) - differential
			dropAnimation.toValue = dropLayers[z].position.y
			dropAnimation.duration = duration * 2
			dropAnimation.beginTime = CACurrentMediaTime() + duration
			dropAnimation.speed = (1 - (Float(z) * 0.1))
			dropAnimation.repeatCount = .infinity
			
			
			
			dropLayers[z].add(dropAnimation, forKey: "position.y")
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
