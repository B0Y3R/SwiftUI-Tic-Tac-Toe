//
//  Alerts.swift
//  SwiftUI-TIK-TAC-TOE
//
//  Created by James Boyer on 12/28/21.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

struct AlertContext {
    static let humanWin = AlertItem(
        title: Text("You Win!"),
        message: Text("Damn son, you beat AI!"),
        buttonTitle: Text("Hell Yeah!")
    )
    
    static let computerWin = AlertItem(
        title: Text("You Lost!"),
        message: Text("Damn son, you messed up!"),
        buttonTitle: Text("Well this sucks!")
    )
    
    static let draw = AlertItem(
        title: Text("DRAW!"),
        message: Text("You both lost!"),
        buttonTitle: Text("Give it another try")
    )
}
