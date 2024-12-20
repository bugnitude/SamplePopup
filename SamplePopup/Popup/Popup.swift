//
//  Popup.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/25.
//

import SwiftUI

@MainActor class Popup: ObservableObject {
	static let shared = Popup()
	private init() {}

	struct ContentInfo {
		let sourceFrame: CGRect
		let width: CGFloat
		let content: (AnchorPosition) -> AnyView
		let onDismiss: () -> Void
		let onComplete: () -> Void

		var dismisses = false
	}

	@Published private(set) var contentInfo: ContentInfo?

	enum AnchorPosition {
		case top(CGFloat)
		case bottom(CGFloat)
	}

	var isPresented: Bool {
		return self.contentInfo != nil
	}

	func present<Content>(sourceFrame: CGRect, width: CGFloat, @ViewBuilder content: @escaping (AnchorPosition) -> Content, onDismiss: @escaping () -> Void) where Content: View {
		guard self.contentInfo == nil else {
			return
		}

		self.contentInfo = .init(sourceFrame: sourceFrame,
								 width: width,
								 content: { AnyView(content($0)) },
								 onDismiss: onDismiss) {
			self.contentInfo = nil
		}
	}

	func dismiss() {
		self.contentInfo?.dismisses = true
	}

//	func dismissImmediately() {
//		guard self.contentInfo != nil else {
//			return
//		}
//
//		self.contentInfo!.onDismiss()
//		self.contentInfo = nil
//	}
}
