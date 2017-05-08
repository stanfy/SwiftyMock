//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation

class RoboKittenV1: RoboKitten {

    func batteryStatus() -> Int {
        return 0
    }

    func jump(x: Int, y: Int) {
    }
    
    func canJumpAt(x: Int, y: Int) -> Bool {
       return false
    }
    
    func rest(_ completed: @escaping (Bool) -> ()) {
        
    }
}
