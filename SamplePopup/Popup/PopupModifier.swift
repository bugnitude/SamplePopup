//
//  PopupModifier.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/05.
//

import SwiftUI

extension View {
	func popup<Content>(isPresented: Binding<Bool>, width: CGFloat = .infinity, @ViewBuilder content: @escaping (Popup.AnchorPosition) -> Content) -> some View where Content: View {
		self.modifier(PopupModifier(isPresented: isPresented, width: width, popupView: content))
	}
}

// MARK: -
private struct PopupModifier<PopupView>: ViewModifier where PopupView: View {
	@Binding var isPresented: Bool
	let width: CGFloat
	@ViewBuilder let popupView: (Popup.AnchorPosition) -> PopupView

	@StateObject private var popup = Popup.shared

	func body(content: Content) -> some View {
		FrameReaderBox(coordinateSpace: .global) { frameReader in
			content
				.onChange(of: self.isPresented) {
					if self.isPresented {
						if !self.popup.isPresented {
							self.popup.present(sourceFrame: frameReader.frame, width: self.width, content: self.popupView) {
								self.isPresented = false
							}
						}
					}
					else {
						if self.popup.isPresented {
							self.popup.dismiss()
						}
					}
				}
				.onChange(of: self.popup.isPresented) {
					if !self.popup.isPresented && self.isPresented {
						self.isPresented = false
					}
				}
		}
	}
}
