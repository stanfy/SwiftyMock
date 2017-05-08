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

    let jump = FunctionCall<(x: Int, y: Int), ()>()
    func jump(x: Int, y: Int)  {
        return stubCall(jump, argument: (x: x, y: y), defaultValue:())
    }
    
    let canJump = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x: Int, y: Int) -> Bool {
        return stubCall(canJump, argument: (x: x, y: y))
    }

    let rest = FunctionCall<(Bool) -> (), ()>()
    func rest(_ completed: @escaping (Bool) -> ()) {
        stubCall(rest, argument: completed, defaultValue: ())
//        return stubCall(restCall, argument: completed, defaultValue: ())
    }

}
