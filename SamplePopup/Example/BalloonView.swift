//
//  BalloonView.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/06.
//

import SwiftUI

struct BalloonView<Content>: View where Content: View {
	let tailPosition: TailPosition
	let tailSize: CGSize
	let cornerRadius: CGFloat
	let color: Color
	@ViewBuilder let content: () -> Content

	enum TailPosition {
		case top(CGFloat)
		case bottom(CGFloat)

		var anchorPosition: CGFloat {
			switch self {
			case .top(let anchorPosition):
				return anchorPosition

			case .bottom(let anchorPosition):
				return anchorPosition
			}
		}
	}

	private enum DetailedTailPosition {
		case topLeading
		case topTrailing
		case topCenter
		case bottomLeading
		case bottomTrailing
		case bottomCenter

		init(tailPosition: TailPosition, tailWidth: CGFloat, cornerRadius: CGFloat, width: CGFloat) {
			let anchorPosition = tailPosition.anchorPosition

			if width - anchorPosition - tailWidth / 2 < cornerRadius {
				switch tailPosition {
				case .top: self = .topTrailing
				case .bottom: self = .bottomTrailing
				}
			}
			else if anchorPosition - tailWidth / 2 < cornerRadius {
				switch tailPosition {
				case .top: self = .topLeading
				case .bottom: self = .bottomLeading
				}
			}
			else {
				switch tailPosition {
				case .top: self = .topCenter
				case .bottom: self = .bottomCenter
				}
			}
		}
	}

	private struct Geometry {
		let apexPosition: CGFloat
		let cornerRadii: RectangleCornerRadii
		let paddingLength: CGFloat

		init(tailPosition: TailPosition, tailWidth: CGFloat, cornerRadius: CGFloat, width: CGFloat) {
			let anchorPosition = tailPosition.anchorPosition

			switch DetailedTailPosition(tailPosition: tailPosition, tailWidth: tailWidth, cornerRadius: cornerRadius, width: width) {
			case .topLeading:
				self.apexPosition = -(tailWidth / 2)
				self.cornerRadii = .init(topLeading: anchorPosition,
										 bottomLeading: cornerRadius,
										 bottomTrailing: cornerRadius,
										 topTrailing: cornerRadius)
				self.paddingLength = anchorPosition

			case .topTrailing:
				self.apexPosition = tailWidth / 2
				self.cornerRadii = .init(topLeading: cornerRadius,
										 bottomLeading: cornerRadius,
										 bottomTrailing: cornerRadius,
										 topTrailing: width - anchorPosition)
				self.paddingLength = anchorPosition - tailWidth

			case .topCenter:
				self.apexPosition = 0
				self.cornerRadii = .init(topLeading: cornerRadius,
										 bottomLeading: cornerRadius,
										 bottomTrailing: cornerRadius,
										 topTrailing: cornerRadius)
				self.paddingLength = anchorPosition - tailWidth / 2

			case .bottomLeading:
				self.apexPosition = -(tailWidth / 2)
				self.cornerRadii = .init(topLeading: cornerRadius,
										 bottomLeading: anchorPosition,
										 bottomTrailing: cornerRadius,
										 topTrailing: cornerRadius)
				self.paddingLength = anchorPosition

			case .bottomTrailing:
				self.apexPosition = tailWidth / 2
				self.cornerRadii = .init(topLeading: cornerRadius,
										 bottomLeading: cornerRadius,
										 bottomTrailing: width - anchorPosition,
										 topTrailing: cornerRadius)
				self.paddingLength = anchorPosition - tailWidth

			case .bottomCenter:
				self.apexPosition = 0
				self.cornerRadii = .init(topLeading: cornerRadius,
										 bottomLeading: cornerRadius,
										 bottomTrailing: cornerRadius,
										 topTrailing: cornerRadius)
				self.paddingLength = anchorPosition - tailWidth / 2
			}
		}
	}

    var body: some View {
		VStack(spacing: 0) {
			switch self.tailPosition {
			case .top:
				Spacer()
					.frame(height: self.tailSize.height)

				self.content()

			case .bottom:
				self.content()

				Spacer()
					.frame(height: self.tailSize.height)
			}
		}
		.frame(maxWidth: .infinity)
		.overlay {
			GeometryReader { geometry in
				Color.clear
					.preference(key: BalloonViewSizePreferenceKey.self, value: geometry.size)
			}
		}
		.backgroundPreferenceValue(BalloonViewSizePreferenceKey.self) { size in
			let geometry = Geometry(tailPosition: self.tailPosition, tailWidth: self.tailSize.width, cornerRadius: self.cornerRadius, width: size.width)

			VStack(spacing: 0) {
				switch self.tailPosition {
				case .top:
					Triangle(apex: .top, apexPosition: geometry.apexPosition)
						.fill(self.color)
						.frame(width: self.tailSize.width, height: self.tailSize.height)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.leading, geometry.paddingLength)

					UnevenRoundedRectangle(cornerRadii: geometry.cornerRadii)
						.fill(self.color)

				case .bottom:
					UnevenRoundedRectangle(cornerRadii: geometry.cornerRadii)
						.fill(self.color)

					Triangle(apex: .bottom, apexPosition: geometry.apexPosition)
						.fill(self.color)
						.frame(width: self.tailSize.width, height: self.tailSize.height)
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.leading, geometry.paddingLength)
				}
			}
		}
		.compositingGroup()
    }
}

// MARK: -
extension BalloonView.TailPosition {
	init(popupAnchorPosition: Popup.AnchorPosition) {
		switch popupAnchorPosition {
		case .top(let anchorPosition):
			self = .top(anchorPosition)

		case .bottom(let anchorPosition):
			self = .bottom(anchorPosition)
		}
	}
}

// MARK: -
private struct BalloonViewSizePreferenceKey: PreferenceKey {
	static let defaultValue = CGSize.zero

	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

// MARK: -
#Preview {
	BalloonView(tailPosition: .bottom(15),
				tailSize: .init(width: 20, height: 20),
				cornerRadius: 20,
				color: .orange) {
		Color.clear
	}
	.frame(width: 200, height: 200)
	.shadow(radius: 20)
}
