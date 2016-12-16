//
//  ViewController.swift
//  QuickInSwift_00
//
//  Created by Jaden Nation on 12/16/16.
//  Copyright © 2016 Jaden Nation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	// MARK: - outlets
	@IBAction func toggleButton(_ sender: UIButton) {
		if let customActivityIndicator = customActivityIndicator {
			if customActivityIndicator.isAnimating {
				customActivityIndicator.stopAnimating()
				sender.setTitle("Start", for: .normal)
			} else {
				customActivityIndicator.startAnimating()
				sender.setTitle("Stop", for: .normal)
			}
		}
	}
	
	
	// MARK: - properties
	var customActivityIndicator: CustomActivityIndicator?
	
	// MARK: - methods
	override func viewDidLayoutSubviews() {
		customActivityIndicator?.center = view.center
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		customActivityIndicator = CustomActivityIndicator(size: CGSize(width: 50, height: 40), withBars: 3, withDuration: 0.35, withColor: .blue)
		view.addSubview(customActivityIndicator!)
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

