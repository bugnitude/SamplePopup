//
//  InfoButton.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/10.
//

import SwiftUI

struct InfoButton: View {
	let message: String

	@State private var isPopupPresented = false

    var body: some View {
		Button {
			self.isPopupPresented = true
		} label: {
			Image(systemName: "info.circle")
				.padding(5)
		}
		.popup(isPresented: self.$isPopupPresented, width: 200) { anchorPosition in
			BalloonView(tailPosition: .init(popupAnchorPosition: anchorPosition), tailSize: .init(width: 15, height: 15), cornerRadius: 6, color: Color.white) {
				ZStack {
					Text("\(self.message)")
				}
				.padding(10)
			}
			.shadow(radius: 10)
			.onTapGesture {
				self.isPopupPresented = false
			}
		}
    }
}

// MARK: -
#Preview {
	ZStack {
		InfoButton(message: "Test")

		PopupContainer()
	}
}
