//
//  Triangle.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/05.
//

import SwiftUI

struct Triangle: Shape {
	enum Apex {
		case top
		case bottom
	}

	let apex: Apex
	let apexPosition: CGFloat

	init(apex: Apex, apexPosition: CGFloat = 0.0) {
		self.apex = apex
		self.apexPosition = apexPosition
	}

	func path(in rect: CGRect) -> Path {
		Path { path in
			switch self.apex {
			case .top:
				path.move(to: CGPoint(x: rect.midX + self.apexPosition, y: rect.minY))
				path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
				path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
				path.closeSubpath()

			case .bottom:
				path.move(to: CGPoint(x: rect.midX + self.apexPosition, y: rect.maxY))
				path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
				path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
				path.closeSubpath()
			}
		}
	}
}

// MARK: -
#Preview {
	Triangle(apex: .bottom, apexPosition: -30)
		.fill(Color.orange)
		.frame(width: 100, height: 100)
}
