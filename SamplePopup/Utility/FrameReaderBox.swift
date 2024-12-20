//
//  FrameReaderBox.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/28.
//

import SwiftUI

struct FrameReaderBox<Content>: View where Content: View {
	let coordinateSpace: CoordinateSpace
	let content: (FrameReader) -> Content

	@StateObject private var frameReader = FrameReader()

	var body: some View {
		self.content(self.frameReader)
			.overlay {
				GeometryReader { geometry in
					Color.clear
						.preference(key: FrameReaderFramePreferenceKey.self, value: geometry.frame(in: self.coordinateSpace))
				}
			}
			.onPreferenceChange(FrameReaderFramePreferenceKey.self) { frame in
				Task { @MainActor in
					self.frameReader.frame = frame
				}
			}
	}
}

// MARK: -
@MainActor final class FrameReader: ObservableObject {
	fileprivate(set) var frame: CGRect = .zero
}

// MARK: -
private struct FrameReaderFramePreferenceKey: PreferenceKey {
	static let defaultValue: CGRect = .zero

	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}
