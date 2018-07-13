// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import SwiftyMock
@testable import SwiftyMock_Example

class FakeLazyRoboKitten: LazyRoboKitten {
    let needsRestGetCall = FunctionVoidCall<Bool>()
    let needsRestSetCall = FunctionCall<Bool, Void>()
    var needsRest: Bool {
        get { return stubCall(needsRestGetCall) }
        set { stubCall(needsRestSetCall, argument: newValue) }
    }

    let batteryStatusCall = FunctionVoidCall<Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall)
    }

    let jumpCall = FunctionCall<(x: Int, y: Int), Void>()
    func jump(x: Int, y: Int) {
        return stubCall(jumpCall, argument: (x: x, y: y), defaultValue: ())
    }

    let canJumpAtCall = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x: Int, y: Int) -> Bool {
        return stubCall(canJumpAtCall, argument: (x: x, y: y))
    }

    let restCall = FunctionCall<(Bool) -> (), Void>()
    func rest(_ completed: @escaping (Bool) -> ()) {
        return stubCall(restCall, argument: completed, defaultValue: ())
    }
}

class FakeRoboKitten: RoboKitten {

    let batteryStatusCall = FunctionVoidCall<Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall)
    }

    let jumpCall = FunctionCall<(x: Int, y: Int), Void>()
    func jump(x: Int, y: Int) {
        return stubCall(jumpCall, argument: (x: x, y: y), defaultValue: ())
    }

    let canJumpAtCall = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x: Int, y: Int) -> Bool {
        return stubCall(canJumpAtCall, argument: (x: x, y: y))
    }

    let restCall = FunctionCall<(Bool) -> (), Void>()
    func rest(_ completed: @escaping (Bool) -> ()) {
        return stubCall(restCall, argument: completed, defaultValue: ())
    }
}
