//
//  ContentView.swift
//  SamplePopup
//
//  Created by kojima on 2024/11/25.
//

import SwiftUI

struct ContentView: View {
	@State private var isTopBarLeadingPopupPresented = false
	@State private var isTopBarTrailingPopupPresented = false
	@State private var isSheetPresented = false

	private enum Item: String, CaseIterable {
		case one = "Item 1"
		case two = "Item 2"
		case three = "Item 3"
	}

	@State private var selectedItem = Item.one
	@State private var selectedItem2 = Item.one

    var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				HStack(spacing: 70) {
					SelectionButton(selectedItem: self.$selectedItem, items: Item.allCases) { item in
						item.rawValue
					}

					InfoButton(message: "Information")
				}

				Spacer()

				HStack(spacing: 0) {
					RoundedSquareButton()

					Spacer()

					RoundedSquareButton()

					Spacer()

					RoundedSquareButton()
				}
				.padding(.horizontal, 50)

				Spacer()
					.frame(height: 50)

				Button {
					self.isSheetPresented = true
				} label: {
					Text("Show Sheet")
				}
			}
			.padding(.vertical, 50)
			.sheet(isPresented: self.$isSheetPresented) {
				SheetView()
			}
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						self.isTopBarLeadingPopupPresented = true
					} label: {
						Image(systemName: "line.3.horizontal")
					}
					.popup(isPresented: self.$isTopBarLeadingPopupPresented, width: 220) { _ in
						MenuView(isPresented: self.$isTopBarLeadingPopupPresented, selectedItem: self.$selectedItem2, items: Item.allCases) { item in
							Text("\(item.rawValue)")
								.foregroundStyle(Color.black)
								.padding(.horizontal, 16)
								.padding(.vertical, 12)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button {
						self.isTopBarTrailingPopupPresented = true
					} label: {
						Image(systemName: "gearshape")
					}
					.popup(isPresented: self.$isTopBarTrailingPopupPresented) { _ in
						NavigationStack {
							ZStack {
								Text("Some Content")
							}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.toolbarBackground(.visible, for: .navigationBar)
							.toolbar {
								ToolbarItem(placement: .topBarTrailing) {
									Button {
										self.isTopBarTrailingPopupPresented = false
									} label: {
										Image(systemName: "xmark")
									}
								}
							}
						}
						.cornerRadius(10)
						.shadow(radius: 10)
					}
				}
			}
		}
    }
}

#Preview {
    ContentView()
}
