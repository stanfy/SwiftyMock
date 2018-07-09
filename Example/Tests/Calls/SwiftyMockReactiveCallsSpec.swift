//
//  SwiftyMockReactiveCallsSpec.swift
//  SwiftyMock_Example
//
//  Created by Alexander Voronov on 11/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
import Result
@testable import SwiftyMock

protocol ReactiveCalculator {
    func sum(left: Int, right: Int) -> SignalProducer<Int, TestError>
}

class TestReactiveCalculator: ReactiveCalculator {
    init() {}

    let sum = ReactiveCall<(left: Int, right: Int), Int, TestError>()
    @discardableResult func sum(left: Int, right: Int) -> SignalProducer<Int, TestError> {
        return stubCall(sum, argument: (left: left, right: right))
    }
}

struct TestError: Error, Equatable {
    let id: Int
    init() { id = 0 }
    init(id: Int) { self.id = id }
}

class SwiftyMockReactiveCallsSpec: QuickSpec {
    override func spec() {
        describe("SwiftyMockReactiveCalls") {
            describe("when correctly setup") {
                var sut: TestReactiveCalculator!
                beforeEach {
                    sut = TestReactiveCalculator()
                }

                context("before calling stubbed method") {
                    it("should tell that method wasn't called") {
                        expect(sut.sum.called).to(beFalsy())
                    }
                    it("should have calls count equal to zero") {
                        expect(sut.sum.callsCount).to(equal(0))
                    }
                    it("should not have captured argument") {
                        expect(sut.sum.capturedArgument).to(beNil())
                    }
                    it("should not have captured arguments") {
                        expect(sut.sum.capturedArguments).to(beEmpty())
                    }
                }

                context("when calling method before stubbing") {
                    fit("should return empty signal without any value") {
                        expect { sut.sum(left: 1,right: 2) }.to(complete())
                    }
                }

                context("when calling stubbed method") {
                    context("with value stub") {
                        beforeEach {
                            sut.sum.returns(.success(12))
                        }

                        it("should return stubbed value and complete") {
                            let result = sut.sum(left: 1, right: 2)
                            expect(result).to(sendValue(12))
                            expect(result).to(complete())
                        }

                        it("should have calls count equal number of calls") {
                            sut.sum(left: 1, right: 2)
                            expect(sut.sum.callsCount).to(equal(1))

                            sut.sum(left: 2, right: 3)
                            sut.sum(left: 3, right: 5)
                            expect(sut.sum.callsCount).to(equal(3))
                        }

                        it("should tell that method was called") {
                            sut.sum(left: 1,right: 2)
                            expect(sut.sum.called).to(beTruthy())
                        }
                    }

                    context("with failure value stub") {
                        beforeEach {
                            sut.sum.returns(.failure(TestError()))
                        }

                        it("should return stubbed error") {
                            expect(sut.sum(left: 1, right: 2)).to(fail(with: TestError()))
                        }
                    }

                    context("with logic stub") {
                        beforeEach {
                            sut.sum.performs { .success($0.left - $0.right) }
                        }

                        it("should calculate method based on the stubbed block") {
                            expect(sut.sum(left: 1, right: 2)).to(sendValue(-1))
                            expect(sut.sum(left: 3, right: 2)).to(sendValue(1))
                        }

                        it("should have calls count equal number of calls") {
                            sut.sum(left: 1, right: 2)
                            expect(sut.sum.callsCount).to(equal(1))

                            sut.sum(left: 2, right: 3)
                            sut.sum(left: 3, right: 5)
                            expect(sut.sum.callsCount).to(equal(3))
                        }

                        it("tell that method was called") {
                            sut.sum(left: 1, right:2)
                            expect(sut.sum.called).to(beTruthy())
                        }
                    }

                    context("with failure logic stub") {
                        beforeEach {
                            sut.sum.performs { _ in .failure(TestError()) }
                        }

                        it("should return stubbed error") {
                            expect(sut.sum(left: 1, right: 2)).to(fail(with: TestError()))
                        }
                    }

                    context("with value and logic stub") {
                        beforeEach {
                            sut.sum.returns(.success(12))
                            sut.sum.performs { .success($0.left + $0.right) }
                        }

                        it("should use logic stub instead of value") {
                            expect(sut.sum(left: 15, right: 12)).to(sendValue(27))
                        }
                    }

                    context("with value and failure logic stub") {
                        beforeEach {
                            sut.sum.returns(.success(12))
                            sut.sum.performs { _ in .failure(TestError()) }
                        }

                        it("should use failure logic stub instead of value") {
                            expect(sut.sum(left: 15, right: 12)).to(fail(with: TestError()))
                        }
                    }

                    context("with failure value and logic stub") {
                        beforeEach {
                            sut.sum.returns(.failure(TestError()))
                            sut.sum.performs { .success($0.left + $0.right) }
                        }

                        it("should use logic stub instead of failure value") {
                            expect(sut.sum(left: 15, right: 12)).to(sendValue(27))
                        }
                    }

                    context("with failure value and failure logic stub") {
                        beforeEach {
                            sut.sum.returns(.failure(TestError(id: 0)))
                            sut.sum.performs { _ in .failure(TestError(id: 1)) }
                        }

                        it("should use failure logic stub instead of failure value") {
                            expect(sut.sum(left: 15, right: 12)).to(fail(with: TestError(id: 1)))
                        }
                    }
                }

                context("when calling filtered value stubbed method") {
                    beforeEach {
                        sut.sum.returns(.success(10))
                        sut.sum.on { $0.left  == 12 }.returns(.success(0))
                        sut.sum.on { $0.right == 15 }.returns(.success(7))
                        sut.sum.on { $0.right == 42 }.returns(.failure(TestError()))
                    }
                    context("when parameters matching filter") {
                        it("should return filter srubbed value") {
                            expect(sut.sum(left: 12, right:  2)).to(sendValue(0))
                            expect(sut.sum(left: 0,  right: 15)).to(sendValue(7))
                            expect(sut.sum(left: 23, right: 42)).to(fail(with: TestError()))
                        }
                    }
                    context("when parameters don't match filters") {
                        it("should return default stubbed value") {
                            expect(sut.sum(left: 13, right: 2)).to(sendValue(10))
                        }
                    }
                }

                context("when calling filtered block stubbed method") {
                    beforeEach {
                        sut.sum.performs { .success($0.left - $0.right) }
                        sut.sum.on { $0.left  == 0  }.performs { _ in .success(0) }
                        sut.sum.on { $0.right == 0  }.performs { _ in .success(12) }
                        sut.sum.on { $0.right == -1 }.performs { _ in .failure(TestError()) }
                    }
                    context("when parameters matching filter") {
                        it("should return call filter-based block") {
                            expect(sut.sum(left: 0,  right:  2)).to(sendValue(0))
                            expect(sut.sum(left: 15, right:  0)).to(sendValue(12))
                            expect(sut.sum(left: 15, right: -1)).to(fail(with: TestError()))
                        }
                    }
                    context("when parameters don't match filters") {
                        it("should call default stubbed block") {
                            expect(sut.sum(left: 13, right: 2)).to(sendValue(11))
                        }
                    }
                }

                context("when calling filtered stubbed with block method") {
                    beforeEach {
                        sut.sum.returns(.success(17))
                        sut.sum.on { $0.left  == 12 }.performs { .success($0.left - $0.right) }
                        sut.sum.on { $0.right == 42 }.performs { _ in .failure(TestError()) }
                    }
                    context("when parameters matching filter") {
                        it("should return calculated with stub value") {
                            expect(sut.sum(left: 12, right:  2)).to(sendValue(10))
                            expect(sut.sum(left: 12, right: 12)).to(sendValue(0))
                            expect(sut.sum(left: 42, right: 12)).to(fail(with: TestError()))
                        }
                    }
                    context("when parameters don't match filters") {
                        it("should return default stubbed value") {
                            expect(sut.sum(left: 13, right: 2)).to(sendValue(17))
                        }
                    }
                }
            }
        }
    }
}
