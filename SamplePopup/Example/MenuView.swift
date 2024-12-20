//
//  MenuView.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/09.
//

import SwiftUI

struct MenuView<Item, Row>: View where Item: Hashable, Row: View {
	@Binding var isPresented: Bool
	@Binding var selectedItem: Item
	let items: [Item]
	let row: (Item) -> Row

    var body: some View {
		VStack(spacing: 0) {
			ForEach(self.items, id: \.self) { item in
				Button {
					self.selectedItem = item
					self.isPresented = false
				} label: {
					self.row(item)
						.contentShape(Rectangle())
				}
				.frame(maxWidth: .infinity)

				if self.items.last != item {
					Divider()
				}
			}
		}
		.frame(maxWidth: .infinity)
		.background {
			Color.white
		}
		.cornerRadius(6)
		.shadow(radius: 20)
    }
}

// MARK: -
//#Preview {
//	MenuView()
//}
