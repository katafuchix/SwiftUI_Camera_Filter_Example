//
//  ContentView.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var model = ViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                FrameView(image: model.frame)
                    .edgesIgnoringSafeArea(.all)

                ErrorView(error: model.error)

                ControlView(
                    startSelected: $model.startSelected,
                    comicSelected: $model.comicFilter,
                    monoSelected: $model.monoFilter,
                    crystalSelected: $model.crystalFilter
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
