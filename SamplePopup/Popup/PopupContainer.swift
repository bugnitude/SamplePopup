//
//  PopupContainer.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/25.
//

import SwiftUI

struct PopupContainer: View {
	@StateObject private var popup = Popup.shared

	var body: some View {
		ZStack {
			if let contentInfo = self.popup.contentInfo {
				PopupContainerView(contentInfo: contentInfo)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

// MARK: -
private struct PopupContainerView: View {
	let contentInfo: Popup.ContentInfo

	@State private var isBackgroundAppeared = false
	@State private var isPopupAppeared = false
	@State private var dismissesPopup = false

	@Namespace private var effectNamespace
	private let effectID = 0
	private let animation = Animation.easeInOut(duration: 0.2)
	private let minMargin = 10.0

	private struct PopupGeometry {
		let sourceFrame: CGRect
		let sourceAnchor: UnitPoint
		let consumerAnchor: UnitPoint
		let width: CGFloat
		let maxHeight: CGFloat

		init(sourceFrame: CGRect, width: CGFloat, containerFrame: CGRect, safeAreaInsets: EdgeInsets, minMargin: CGFloat) {
			let availableWidth = containerFrame.width - 2 * minMargin
			let availableHeight = containerFrame.height - 2 * minMargin
			let availableFrame = CGRect(x: safeAreaInsets.leading + minMargin, y: safeAreaInsets.top + minMargin, width: availableWidth, height: availableHeight)
			let globalFrame = CGRect(x: 0, y: 0, width: containerFrame.width + safeAreaInsets.leading + safeAreaInsets.trailing, height: containerFrame.height + safeAreaInsets.top + safeAreaInsets.bottom)

			let adjustedSourceFrame: CGRect
			if availableFrame.intersects(sourceFrame) {
				adjustedSourceFrame = availableFrame.intersection(sourceFrame)
			}
			else {
				var intersectedRect = sourceFrame
				if sourceFrame.maxX < availableFrame.minX {
					intersectedRect.origin.x += availableFrame.minX - sourceFrame.maxX
				}
				else if sourceFrame.minX > availableFrame.maxX {
					intersectedRect.origin.x -= sourceFrame.minX - availableFrame.maxX
				}

				if sourceFrame.maxY < availableFrame.minY {
					intersectedRect.origin.y += availableFrame.minY - sourceFrame.maxY
				}
				else if sourceFrame.minY > availableFrame.maxY {
					intersectedRect.origin.y -= sourceFrame.minY - availableFrame.maxY
				}

				adjustedSourceFrame = availableFrame.intersection(intersectedRect)
			}

			let inTop = adjustedSourceFrame.minY < globalFrame.midY
			let inLeading = adjustedSourceFrame.midX < globalFrame.width / 3
			let inTrailing = adjustedSourceFrame.midX > globalFrame.width * 2 / 3

			let sourceAnchor: UnitPoint = inTop ? .bottom : .top
			let maxHeight: CGFloat = inTop ? availableFrame.maxY - adjustedSourceFrame.maxY : adjustedSourceFrame.minY - availableFrame.minY

			let consumerAnchor: UnitPoint
			let adjustedWidth: CGFloat
			switch (inLeading, inTrailing) {
			case (true, false):
				adjustedWidth = min(max(width, 1), availableFrame.maxX - adjustedSourceFrame.minX)
				consumerAnchor = .init(x: adjustedSourceFrame.width / 2 / adjustedWidth, y: inTop ? 0.0 : 1.0)

			case (false, true):
				adjustedWidth =	min(max(width, 1), adjustedSourceFrame.maxX - availableFrame.minX)
				consumerAnchor = .init(x: (1 - adjustedSourceFrame.width / 2 / adjustedWidth), y: inTop ? 0.0 : 1.0)

			default:
				adjustedWidth = min(max(width, 0), availableWidth)
				consumerAnchor = inTop ? .top : .bottom
			}

			self.sourceFrame = adjustedSourceFrame
			self.sourceAnchor = sourceAnchor
			self.consumerAnchor = consumerAnchor
			self.width = adjustedWidth
			self.maxHeight = maxHeight
		}

		var anchorPosition: Popup.AnchorPosition {
			switch self.consumerAnchor.y {
			case 0.0:
				return .top(self.width * self.consumerAnchor.x)

			case 1.0:
				return .bottom(self.width * self.consumerAnchor.x)

			default:
				fatalError()
			}
		}
	}

	var body: some View {
		Color.white.opacity(0.01)
			.ignoresSafeArea()
			.onTapGesture {
				self.dismissesPopup = true
			}
			.overlay {
				GeometryReader { geometry in
					Color.clear
						.preference(key: PopupContainerPreferenceKey.self, value: .init(frame: geometry.frame(in: .global), safeAreaInsets: geometry.safeAreaInsets))
				}
			}
			.overlayPreferenceValue(PopupContainerPreferenceKey.self) { container in
				if container.frame != .zero {
					let geometry = PopupGeometry(sourceFrame: self.contentInfo.sourceFrame, width: self.contentInfo.width, containerFrame: container.frame, safeAreaInsets: container.safeAreaInsets, minMargin: self.minMargin)

					ZStack {
						Color.clear
							.matchedGeometryEffect(id: self.effectID, in: self.effectNamespace, properties: .position, anchor: geometry.sourceAnchor, isSource: true)
							.frame(width: geometry.sourceFrame.width, height: geometry.sourceFrame.height)
							.position(x: geometry.sourceFrame.midX, y: geometry.sourceFrame.midY)

						if self.isBackgroundAppeared {
							self.contentInfo.content(geometry.anchorPosition)
								.matchedGeometryEffect(id: self.effectID, in: self.effectNamespace, properties: .position, anchor: geometry.consumerAnchor, isSource: false)
								.frame(width: geometry.width)
								.frame(maxHeight: geometry.maxHeight)
								.scaleEffect(self.isPopupAppeared ? 1.0 : 0.2)
								.opacity(self.isPopupAppeared ? 1.0 : 0.0)
								.onAppear {
									withAnimation(self.animation) {
										self.isPopupAppeared = true
									}
								}
								.onDisappear {
									self.contentInfo.onComplete()
								}
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.ignoresSafeArea()
					.environment(\.layoutDirection, .leftToRight)
					.onAppear {
						self.isBackgroundAppeared = true
					}
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				self.dismissesPopup = true
			}
			.onChange(of: self.contentInfo.dismisses) {
				if self.contentInfo.dismisses {
					self.dismissesPopup = true
				}
			}
			.onChange(of: self.dismissesPopup) {
				if self.dismissesPopup {
					self.contentInfo.onDismiss()

					withAnimation(self.animation) {
						self.isPopupAppeared = false
					} completion: {
						self.isBackgroundAppeared = false
					}
				}
			}
	}
}

// MARK: -
private struct PopupContainerPreferenceKey: PreferenceKey {
	struct Container {
		let frame: CGRect
		let safeAreaInsets: EdgeInsets
	}

	static let defaultValue = Container(frame: .zero, safeAreaInsets: .init())

	static func reduce(value: inout Container, nextValue: () -> Container) {
		value = nextValue()
	}
}
