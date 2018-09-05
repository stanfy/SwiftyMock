// Generated using Sourcery 0.14.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import SwiftyMock
import ReactiveSwift
import Result
@testable import SwiftyMock_Example

class FakeLazyRoboKitten: LazyRoboKitten {
    var needsRest: Bool

    let wantsToEatGetCall = FunctionCall<Void, Bool>()
    let wantsToEatSetCall = FunctionCall<Bool, Void>()
    var wantsToEat: Bool {
        get { return stubCall(wantsToEatGetCall, argument: ()) }
        set { stubCall(wantsToEatSetCall, argument: newValue) }
    }

    init(needsRest: Bool) {
        self.needsRest = needsRest
    }

    let sleepCall = ReactiveCall<Int, Bool, NSError>()
    func sleep(hours: Int) -> SignalProducer<Bool, NSError> {
        return stubCall(sleepCall, argument: hours)
    }

    let batteryStatusCall = FunctionCall<(), Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall, argument: ())
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


    let batteryStatusCall = FunctionCall<(), Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall, argument: ())
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
