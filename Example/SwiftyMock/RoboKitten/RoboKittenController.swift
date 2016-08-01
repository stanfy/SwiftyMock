//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation

enum BatteyStatus {
    case LOW
    case NORMAL
    case FULL
}

enum Result {
    case SUCCESS
    case FAILURE
}


class RoboKittenController {
    let kitten: RoboKitten

    init(kitten: RoboKitten) {
        self.kitten = kitten
    }
    
    func batteryStatus() -> BatteyStatus {
        if kitten.batteryStatus() >= 100 {
            return .FULL
        }
        if (kitten.batteryStatus() < 10) {
            return .LOW
        }
        return .NORMAL
    }
    
    func jumpAt(x x: Int, y: Int) -> Result {
        if kitten.canJumpAt(x: x, y: y) {
            kitten.jump(x: x, y: y)
            return .SUCCESS
        }
        return .FAILURE
    }

    func jump(inSequence sequence: [(x: Int, y: Int)]) -> Result {
        for coords in sequence {
            if !kitten.canJumpAt(x: coords.x, y: coords.y) {
                return .FAILURE
            }
        }
        for coords in sequence {
            kitten.jump(x: coords.x, y: coords.y)
        }
        return .SUCCESS
    }

    func rest(completion: Result -> ()) {
        kitten.rest { successfuly in
            switch successfuly {
                case true: completion(.SUCCESS)
                case false: completion(.FAILURE)
            }
        }
    }

}
