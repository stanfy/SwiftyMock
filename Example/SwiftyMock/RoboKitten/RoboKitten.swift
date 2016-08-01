//
// Created by Paul Taykalo on 7/31/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation

protocol RoboKitten {
    func batteryStatus() -> Int
    func jump(x x: Int, y: Int) -> Int
    func canJumpAt(x x: Int, y: Int) -> Bool
    func rest(completed: Bool -> () )
}