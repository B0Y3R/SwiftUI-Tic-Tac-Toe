//
//  GameView.swift
//  SwiftUI-TIK-TAC-TOE
//
//  Created by James Boyer on 12/28/21.
//

import SwiftUI



struct GameView: View {
    
    // inital board, array of 9 nils
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisabled: Bool = false
    @State private var alertItem: AlertItem?
    
    let winPatterns: Set<Set<Int>> = [
                                        // Horizontal Win ***
                                        [0, 1, 2],
                                        [3, 4, 5],
                                        [6, 7, 8],
                                        
                                        // Vertical Win
                                        [0, 3, 6],
                                        [1, 4, 7],
                                        [2, 5, 8],
                                        
                                        // Diagonal Win
                                        [0, 4, 8],
                                        [2, 4, 6]
                                     ]
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        // Geometry Reader gives us access to the screen sizes (diff phones have diff screen sizes)
        GeometryReader { geometry in
            VStack {
                Spacer()
                LazyVGrid(columns: columns) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Image(systemName: moves[i]?.indicator ?? "" )
                                .resizable()
                                .frame(
                                    width: geometry.size.width / 6,
                                    height: geometry.size.width / 6
                                )
                            
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(
                                    width: geometry.size.width / 3 - 15,
                                    height: geometry.size.width / 3 - 15
                                )
                        }
                        .onTapGesture {
                            if !isSquareOccupied(in: moves, forIndex: i) {
                                moves[i] = Move(player: .human, boardIndex: i)
                            
                                
                                // check for win condition or draw
                                if checkWinCondition(for: .human, in: moves) {
                                    alertItem = AlertContext.humanWin
                                    return
                                }
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    return
                                }
                                
                                // disable the gameBoard after users makes move
                                isGameBoardDisabled = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let computerPosition = determineComputerMovePosition(in: moves)
                                
                                
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition);
                                
                                // enable the gameBoard after the computer makes its move
                                isGameBoardDisabled = false
                                
                                // check for win condition or draw
                                if checkWinCondition(for: .computer, in: moves) {
                                    alertItem = AlertContext.computerWin
                                    return
                                }
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.draw
                                    return
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .disabled(isGameBoardDisabled)
            .padding()
            .alert(item: $alertItem, content: { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: .default(alertItem.buttonTitle, action: { resetGame() } )
                )
            })
        }
    }
    
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: { $0?.boardIndex == index })
    }
    
    // if AI can win, then win
    // if AI can't win, then block
    // if AI can't block, then take the middle square
    // if AI can't take the middle square, then take random available square
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        let humanPositions = Set(humanMoves.map { $0.boardIndex })
        
        // for each pattern, in winPatterns i.e [0,1,2]
        for patterns in winPatterns {
            
            // take that pattern and subtract matching values from computerPositions
            // ex: [0,1,2] and computerPositions = [0,1] winPositions would equal [2]
            let winPositions = patterns.subtracting(computerPositions)
            
            // if AI can win, then win
            if winPositions.count == 1 {
                print("AI GOING FOR THE WIN <<<<<")
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
            
            // if AI can't win, then block
            if winPositions.count != 1 {
                // calculate block positions by subtracting humans positions from
                // each pattern and seeing what index's are left over
                let blockPositions = patterns.subtracting(humanPositions)
                
                if blockPositions.count == 1 {
                    print("WE HIT THE BLOCK <<<<<<<")
                    let isAvailable = !isSquareOccupied(in: moves, forIndex: blockPositions.first!)
                    if isAvailable { return blockPositions.first!}
                }
                
                // if AI can't block, then take the middle square
                let centerIndex = 4
                if blockPositions.count == 0 {
                    print("AI GOING FOR THE MIDDLE <<<<<<")
                    let isAvialable = !isSquareOccupied(in: moves, forIndex: centerIndex)
                    if isAvialable { return centerIndex }
                }
            }
        }
        
        print("AI DOESNT KNOW HOW TO DEAL <<<<<")
        
        // if AI can't take the middle square, then take random available square
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
             movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition;
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {

        
        // compactMap removes all of the nil values
        // this gives us all the moves without the nils
        // then runs filter to grab only the current players moves
        
        // $0 represents a single element in an array
        let playerMoves = moves.compactMap { $0 }.filter {$0.player == player}
        
        // creates a Set of player moves board Indexes that we'll compare
        // to the win Patterns for a bool result
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        // iterate through our winPatterns and check if any of our playerPostions
        // are a subSet of the winPatterns, if so we have a winner
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        // were going to use compactMap to remove all the nils form the array
        // if the length of the array is 9, we return true
        
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
    }
    
}



enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
