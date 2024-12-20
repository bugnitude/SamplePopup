//
//  RoundedSquareButton.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/10.
//

import SwiftUI

struct RoundedSquareButton: View {
	@State private var isPopupPresented = false

    var body: some View {
		Button {
			self.isPopupPresented = true
		} label: {
			RoundedRectangle(cornerRadius: 6)
				.frame(width: 50, height: 50)
		}
		.padding(5)
		.popup(isPresented: self.$isPopupPresented, width: 200) { anchorPosition in
			BalloonView(tailPosition: .init(popupAnchorPosition: anchorPosition), tailSize: .init(width: 15, height: 15), cornerRadius: 6, color: Color.white) {
				ZStack {
					Text("Some Content")
				}
				.frame(height: 200)
			}
			.shadow(radius: 20)
			.onTapGesture {
				self.isPopupPresented = false
			}
		}
	}
}

#Preview {
    RoundedSquareButton()
}
