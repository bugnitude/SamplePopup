//
//  SelectionButton.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/09.
//

import SwiftUI

struct SelectionButton<Item>: View where Item: Hashable {
	@Binding var selectedItem: Item
	let items: [Item]
	let title: (Item) -> String

	@State private var isPopupPresented = false

	var body: some View {
		Button {
			self.isPopupPresented = true
		} label: {
			HStack(spacing: 0) {
				Text("\(self.title(self.selectedItem))")
					.font(.system(size: 16))

				Spacer()

				Image(systemName: "triangleshape.fill")
					.font(.system(size: 10))
					.rotationEffect(.degrees(self.isPopupPresented ? 0 : 180))
					.animation(.linear(duration: 0.2), value: self.isPopupPresented)
			}
			.padding(16)
			.frame(width: 200, height: 50)
			.foregroundStyle(Color.white)
			.background {
				Color.blue
			}
			.cornerRadius(6)
			.contentShape(Rectangle())
		}
		.popup(isPresented: self.$isPopupPresented, width: 200) { _ in
			MenuView(isPresented: self.$isPopupPresented, selectedItem: self.$selectedItem, items: self.items) { item in
				HStack(spacing: 0) {
					Text("\(self.title(item))")
						.foregroundStyle(Color.black)

					Spacer()

					Image(systemName: "checkmark")
						.opacity(self.selectedItem == item ? 1.0 : 0.0)
				}
				.font(.system(size: 16))
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
			}
		}
	}
}

// MARK: -
#Preview {
	ZStack {
		Preview()

		PopupContainer()
	}
}

private struct Preview: View {
	@State private var selectedItem: Item = .one

	enum Item: String, CaseIterable {
		case one = "Item 1"
		case two = "Item 2"
		case three = "Item 3"
	}

	var body: some View {
		SelectionButton(selectedItem: self.$selectedItem, items: Item.allCases) { item in
			item.rawValue
		}
	}
}
