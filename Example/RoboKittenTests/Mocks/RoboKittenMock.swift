//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyMock
@testable import SwiftyMock_Example

class RoboKittenMock: RoboKitten {

    let batteryStatusCall = FunctionCall<(), Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall, argument:())
    }

    let jump = FunctionCall<(x: Int, y: Int), Int>()
    func jump(x x: Int, y: Int) -> Int {
        return stubCall(jump, argument: (x: x, y: y))
    }
    
    let canJump = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x x: Int, y: Int) -> Bool {
        return stubCall(canJump, argument: (x: x, y: y))
    }
}
