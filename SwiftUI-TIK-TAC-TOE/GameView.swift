//
//  GameView.swift
//  SwiftUI-TIK-TAC-TOE
//
//  Created by James Boyer on 12/28/21.
//

import SwiftUI

struct CircleView: View {
    
    var indicator: String
    var imageSize: CGFloat
    var circleSize: CGFloat
    var viewModel: GameViewModel
    var index: Int = 0

    
    var body: some View {
        ZStack {
            Image(systemName: indicator )
                .resizable()
                .frame(
                    width: imageSize,
                    height: imageSize
                )
            
            Circle()
                .foregroundColor(.red)
                .opacity(0.5)
                .frame(
                    width: circleSize,
                    height: circleSize
                )
        }
        .onTapGesture {
            viewModel.processPlayerMove(position: index)
        }
    }
}

struct GameView: View {
    
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        // Geometry Reader gives us access to the screen sizes (diff phones have diff screen sizes)
        GeometryReader { geometry in
            VStack {
                Spacer()
                LazyVGrid(columns: viewModel.columns) {
                    ForEach(0..<9) { i in
                        CircleView(
                            indicator: viewModel.moves[i]?.indicator ?? "",
                            imageSize:  geometry.size.width / 6,
                            circleSize: geometry.size.width / 3 - 15,
                            viewModel: viewModel,
                            index: i
                        )
                    }
                }
                Spacer()
            }
            .disabled(viewModel.isGameBoardDisabled)
            .padding()
            .alert(item: $viewModel.alertItem, content: { alertItem in
                Alert(
                    title: viewModel.alertItem!.title,
                    message: viewModel.alertItem?.message,
                    dismissButton: .default(alertItem.buttonTitle, action: { viewModel.resetGame() } )
                )
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
