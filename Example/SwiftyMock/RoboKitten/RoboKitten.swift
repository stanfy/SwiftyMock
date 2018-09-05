//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation
import ReactiveSwift

// sourcery: Mock
protocol RoboKitten {
    @discardableResult func batteryStatus() -> Int
    func jump(x: Int, y: Int)
    @discardableResult func canJumpAt(x: Int, y: Int) -> Bool
    func rest(_ completed: @escaping (Bool) -> ())
}

// sourcery: Mock
protocol LazyRoboKitten: RoboKitten {
    // sourcery: skipMock
	var needsRest: Bool { get set }
    var wantsToEat: Bool { get set }

    func sleep(hours: Int) -> SignalProducer<Bool, NSError>
}
