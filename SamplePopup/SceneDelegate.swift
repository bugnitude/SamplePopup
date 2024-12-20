//
//  SceneDelegate.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	private var overlayWindow: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = scene as? UIWindowScene else {
			return
		}

		let overlayViewHostingController = UIHostingController(rootView: OverlayView())
		overlayViewHostingController.view.backgroundColor = .clear

		let overlayWindow = PassThroughWindow(windowScene: windowScene)
		overlayWindow.rootViewController = overlayViewHostingController
		overlayWindow.isHidden = false
		self.overlayWindow = overlayWindow
	}
}
