//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation

enum BatteyStatus: Equatable {
    case low
    case normal
    case full
}

enum Result {
    case success
    case failure
}


class RoboKittenController {
    let kitten: RoboKitten

    init(kitten: RoboKitten) {
        self.kitten = kitten
    }
    
    @discardableResult func batteryStatus() -> BatteyStatus {
        if kitten.batteryStatus() >= 100 {
            return .full
        }
        if (kitten.batteryStatus() < 10) {
            return .low
        }
        return .normal
    }
    
    @discardableResult func jumpAt(x: Int, y: Int) -> Result {
        if kitten.canJumpAt(x: x, y: y) {
            kitten.jump(x: x, y: y)
            return .success
        }
        return .failure
    }

     @discardableResult func jump(inSequence sequence: [(x: Int, y: Int)]) -> Result {
        for coords in sequence {
            if !kitten.canJumpAt(x: coords.x, y: coords.y) {
                return .failure
            }
        }
        for coords in sequence {
            kitten.jump(x: coords.x, y: coords.y)
        }
        return .success
    }

    func rest(_ completion: @escaping (Result) -> ()) {
        kitten.rest { successfuly in
            switch successfuly {
                case true: completion(.success)
                case false: completion(.failure)
            }
        }
    }

}

