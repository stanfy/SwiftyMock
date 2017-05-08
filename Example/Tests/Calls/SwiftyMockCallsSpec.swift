//
//  SwiftyMockCallsSpec.swift
//  SwiftyMock
//
//  Created by Paul Taykalo on 7/29/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SwiftyMock

protocol Calculator {
    func sum(left: Int, right: Int) -> Int
}

class TestCalculator: Calculator {
    let sum = FunctionCall<(left: Int, right: Int), Int>()
    @discardableResult func sum(left: Int, right: Int) -> Int {
        return stubCall(sum, argument: (left: left, right: right))
    }
}

class SwiftyMockCallsSpec: QuickSpec {
    override func spec() {
        describe("SwiftyMockCalls") {
            describe("when correctly setup") {
                var sut: TestCalculator!
                beforeEach {
                    sut = TestCalculator()
                }
                
                context("before calling stubbed method") {
                    it("should tell that method wasnt' called") {
                        expect(sut.sum.called).to(beFalsy())
                    }
                    it("should have calls count equal to zero") {
                        expect(sut.sum.callsCount).to(equal(0))
                    }
                    it("should not have captured argumen") {
                        expect(sut.sum.capturedArgument).to(beNil())
                    }
                    
                    it("should not have captured argumens") {
                        expect(sut.sum.capturedArguments).to(beEmpty())
                    }
                    
                }
                context("when calling method before stubbing") {
                    xit("should fail with assertion") {
                        expect { sut.sum(left: 1,right: 2) }.to(raiseException())
                    }
                }
                context("when calling stubbed method") {
                    context("with value stub") {
                        beforeEach {
                            sut.sum.returns(12)
                        }
                        it("should return stubbed value") {
                            expect(sut.sum(left: 1,right:2)).to(equal(12))
                        }
                        it("should have calls count equal number of calls") {
                            sut.sum(left: 1,right:2)
                            expect(sut.sum.callsCount).to(equal(1))
                            
                            sut.sum(left: 2,right:3)
                            sut.sum(left: 3,right:5)
                            expect(sut.sum.callsCount).to(equal(3))
                        }
                        
                        it("tell that method was called") {
                            sut.sum(left: 1,right:2)
                            expect(sut.sum.called).to(beTruthy())
                        }
                    }
                    context("with logic stub") {
                        beforeEach {
                            sut.sum.performs { $0.left - $0.right }
                        }
                        it("should calculate method based on the stubbed block") {
                            expect(sut.sum(left: 1, right:2)).to(equal(-1))
                            expect(sut.sum(left: 3, right:2)).to(equal(1))
                        }
                        it("should have calls count equal number of calls") {
                            sut.sum(left: 1,right:2)
                            expect(sut.sum.callsCount).to(equal(1))
                            
                            sut.sum(left: 2,right:3)
                            sut.sum(left: 3,right:5)
                            expect(sut.sum.callsCount).to(equal(3))
                        }
                        
                        it("tell that method was called") {
                            sut.sum(left: 1,right:2)
                            expect(sut.sum.called).to(beTruthy())
                        }
                    }
                    
                    context("with logic and value stub") {
                        beforeEach {
                            sut.sum.returns(12)
                            sut.sum.performs { $0.left + $0.right}
                        }

                        it("should use logic stub instead of value") {
                            expect(sut.sum(left: 15, right:12)).to(equal(27))
                        }
                    }
                }
                
                context("when calling filtered value stubbed method") {
                    beforeEach {
                        sut.sum.returns(10)
                        sut.sum.on { $0.left == 12 }.returns(0)
                        sut.sum.on { $0.right == 15 }.returns(7)
                    }
                    context("when parameters matching filter") {
                        it("should return filter srubbed value") {
                            expect(sut.sum(left: 12,right:2)).to(equal(0))
                            expect(sut.sum(left: 0,right:15)).to(equal(7))
                        }
                    }
                    context("when parameters doesn't match filters") {
                        it("should return default stubbed value") {
                            expect(sut.sum(left: 13,right:2)).to(equal(10))
                        }
                    }
                }
                
                context("when calling filtered block stubbed method") {
                    beforeEach {
                        sut.sum.performs { $0.left + $0.right }
                        sut.sum.on { $0.left == 0 }.performs { _ in 0 }
                        sut.sum.on { $0.right == 0 }.performs { _ in 12 }
                    }
                    context("when parameters matching filter") {
                        it("should return call filter-based block") {
                            expect(sut.sum(left: 0,right:2)).to(equal(0))
                            expect(sut.sum(left: 15,right:0)).to(equal(12))
                        }
                    }
                    context("when parameters doesn't match filters") {
                        it("should return call default stubbed block") {
                            expect(sut.sum(left: 13,right:2)).to(equal(15))
                        }
                    }
                }
                
                
                context("when calling filtered stubbed with block method") {
                    beforeEach {
                        sut.sum.returns(17)
                        sut.sum.on { $0.left == 12 }.performs { $0.left + $0.right }
                    }
                    context("when parameters matching filter") {
                        it("should return calculated with stub value") {
                            expect(sut.sum(left: 12,right:2)).to(equal(14))
                            expect(sut.sum(left: 12,right:12)).to(equal(24))
                        }
                    }
                    context("when parameters doesn't match filters") {
                        it("should return default stubbed value") {
                            expect(sut.sum(left: 13,right:2)).to(equal(17))
                        }
                    }
                }
            }
        }
    }
}

