//
//  SheetView.swift
//  SamplePopup
//
//  Created by kojima on 2024/12/10.
//

import SwiftUI

struct SheetView: View {
    var body: some View {
		NavigationStack {
			ZStack {
				RoundedSquareButton()
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbarBackground(.visible, for: .navigationBar)
		}
    }
}

#Preview {
    SheetView()
}
