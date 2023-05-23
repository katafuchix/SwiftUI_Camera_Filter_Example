//
//  ControlView.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import SwiftUI

struct ControlView: View {
    @Binding var startSelected: Bool
    @Binding var comicSelected: Bool
    @Binding var monoSelected: Bool
    @Binding var crystalSelected: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
            ToggleButton(selected: $startSelected, label: "Start")
            ToggleButton(selected: $comicSelected, label: "Comic")
            ToggleButton(selected: $monoSelected, label: "Mono")
            ToggleButton(selected: $crystalSelected, label: "Crystal")
            }
        }
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            ControlView(
                startSelected: .constant(false),
                comicSelected: .constant(false),
                monoSelected: .constant(true),
                crystalSelected: .constant(true)
            )
        }
    }
}
