//
//  RoboKittenControllerSpec.swift
//  SwiftyMock
//
//  Created by Paul Taykalo on 7/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
@testable import SwiftyMock_Example

import Quick
import Nimble
import SwiftyMock

class RoboKittenControllerSpec: QuickSpec {
    override func spec() {
        describe("RoboKittenController") {
            var sut: RoboKittenController!
            var kittenMock: FakeRoboKitten!
            beforeEach {
                kittenMock = FakeRoboKitten()
                sut = RoboKittenController(kitten: kittenMock)
            }
            
            describe("when checked for battery status") {
                it("should return LOW battery status for battery level < 10") {
                    kittenMock.batteryStatusCall.returns(5)
                    expect(sut.batteryStatus()).to(equal(BatteyStatus.low))
                }
                it("should return FULL battery status for battery level >= 100") {
                    kittenMock.batteryStatusCall.returns(100)
                    expect(sut.batteryStatus()).to(equal(BatteyStatus.full))
                    
                    kittenMock.batteryStatusCall.returns(210)
                    expect(sut.batteryStatus()).to(equal(BatteyStatus.full))
                }
                
                it("should return NORMAL battery status for battery level between 10..100") {
                    kittenMock.batteryStatusCall.returns(15)
                    expect(sut.batteryStatus()).to(equal(BatteyStatus.normal))
                    
                    kittenMock.batteryStatusCall.returns(30)
                    expect(sut.batteryStatus()).to(equal(BatteyStatus.normal))
                }
            }
            
            describe("when asked to jump somewhere") {
                beforeEach {
                    kittenMock.canJumpAtCall.returns(false)
                }
                it("should ask kitten if it's available to jump there") {
                    sut.jumpAt(x: 10, y: 20)
                    expect(kittenMock.canJumpAtCall.called).to(beTruthy())
                }
                
                it("should ask kitten if it's available to jump there with the same coords") {
                    sut.jumpAt(x: 10, y: 20)
                    expect(kittenMock.canJumpAtCall.capturedArgument?.x).to(equal(10))
                    expect(kittenMock.canJumpAtCall.capturedArgument?.y).to(equal(20))
                }
                
                context("and kitten can jump there") {
                    beforeEach {
                        kittenMock.canJumpAtCall.returns(true)
                    }
                    it("should actually ask kitten to jump") {
                        sut.jumpAt(x: 15, y: 30)
                        expect(kittenMock.jumpCall.called).to(beTruthy())
                        expect(kittenMock.jumpCall.capturedArgument?.x).to(equal(15))
                        expect(kittenMock.jumpCall.capturedArgument?.y).to(equal(30))
                    }
                    
                    it("should actually ask kitten to jump only once per call") {
                        sut.jumpAt(x: 18, y: 23)
                        expect(kittenMock.jumpCall.callsCount).to(equal(1))
                        
                        sut.jumpAt(x: 80, y: 15)
                        expect(kittenMock.jumpCall.callsCount).to(equal(2))
                    }
                    
                    it("return success result") {
                        expect(sut.jumpAt(x: 10, y: 20)).to(equal(Result.success))
                    }
                }
                
                context("and kitten cannot jump there") {
                    beforeEach {
                        kittenMock.canJumpAtCall.returns(false)
                    }

                    it("should shouldn't ask kitten to jump") {
                        sut.jumpAt(x: 15, y: 30)
                        expect(kittenMock.jumpCall.called).to(beFalsy())
                    }
                    it("shouldreturn failure result") {
                        expect(sut.jumpAt(x: 10, y: 20)).to(equal(Result.failure))
                    }
                }
                
            }
            
            describe("when asked to perform multiple jumps") {
                context("and kitten can perform all of them") {
                    beforeEach {
                        kittenMock.canJumpAtCall.returns(true)
                    }
                    it("should return success result") {
                        expect(sut.jump(inSequence: [(x: 10, y: 20), (x: 12, y: 20)])).to(equal(Result.success))
                    }
                    
                    it("should call jump on each passed parameter in the correct order") {
                        let sequence = [(x: 15, y: 21), (x: 23, y: 21)]
                        sut.jump(inSequence: sequence)
                        expect(kittenMock.jumpCall.callsCount).to(equal(2))
                        expect(kittenMock.jumpCall.capturedArguments[0].x).to(equal(15))
                        expect(kittenMock.jumpCall.capturedArguments[0].y).to(equal(21))
                        
                        expect(kittenMock.jumpCall.capturedArguments[1].x).to(equal(23))
                        expect(kittenMock.jumpCall.capturedArguments[1].y).to(equal(21))
                    }
                }
                
                context("And kitten can not jump at some coordinates") {
                    beforeEach {
                        kittenMock.canJumpAtCall
                            .on { $0.x < 0 }.returns(false)
                            .on { $0.y < 0 }.returns(false)
                            .returns(true) // in all other cases
                        
                    }
                    context("and there are some coordinates where kitten cannot jump at in passed in sequence") {
                        it("should return failure result") {
                            expect(sut.jump(inSequence: [(x: -10, y: 20), (x: 12, y: 20)])).to(equal(Result.failure))
                            expect(sut.jump(inSequence: [(x: 10, y: -20), (x: 12, y: 20)])).to(equal(Result.failure))
                            expect(sut.jump(inSequence: [(x: 10, y: -20), (x: -12, y: 20)])).to(equal(Result.failure))
                            expect(sut.jump(inSequence: [(x: 10, y: -20), (x: 12, y: -20)])).to(equal(Result.failure))
                        }
                        it("should not ask kitten to jump at all") {
                            sut.jump(inSequence: [(x: -10, y: 20), (x: 12, y: 20)])
                            
                            expect(kittenMock.jumpCall.called).to(beFalsy())
                        }
                    }
                    
                    context("and there are no coordinates where kitten cannot jump at in passed in sequence") {
                        it("should return success result in case if there's no coords where kittent cannot jump at") {
                            expect(sut.jump(inSequence: [(x: 10, y: 20), (x: 12, y: 20)])).to(equal(Result.success))
                        }
                    }
                }
            }

            context("when asked to rest") {

                it("should ask kitten to rest") {
                    sut.rest { _ in }
                    expect(kittenMock.restCall.called).to(beTruthy())
                }

                context("and kitten rests successfully") {
                    beforeEach {
                        kittenMock.restCall.performs { completion in
                            completion(true)
                        }
                    }
                    it("should return successful result") {
                        var result: Result?
                        sut.rest { restResult in
                            result = restResult
                        }
                        expect(result).to(equal(.success))
                    }
                }

                context("and kitten fails to rest") {
                    beforeEach {
                        kittenMock.restCall.performs { completion in
                            completion(false)
                        }
                    }
                    it("should return failure result") {
                        var result: Result?
                        sut.rest { restResult in
                            result = restResult
                        }
                        expect(result).to(equal(.failure))
                    }
                }

            }
        }
    }
}

