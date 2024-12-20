//
//  PassThroughWindow.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/28.
//

import UIKit

class PassThroughWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard let hitView = super.hitTest(point, with: event), let rootView = self.rootViewController?.view else {
			return nil
		}

		if #available(iOS 18, *) {
			for subview in rootView.subviews.reversed() {
				let convertedPoint = subview.convert(point, from: rootView)
				if subview.hitTest(convertedPoint, with: event) != nil {
					return hitView
				}
			}

			return nil
		}
		else {
			return hitView == rootView ? nil : hitView
		}
	}
}