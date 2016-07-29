# SwiftyMock [![Build Status](https://travis-ci.org/stanfy/SwiftyMock.svg?branch=master)](https://travis-ci.org/stanfy/SwiftyMock)

This repository contains helpers that make mocking, stubbing and spying in Swift much easier

# Example

```swift
// Imagine you have some protocol that describes some behaviour

protocol Doable {
    func doSomething() -> Int
    func doSomethingWithArgs(x: Int, y: Int) -> Int
    func doSomethingReactive(x: Int) -> SignalProducer<Int, NoError>
}

// And you have some implementation of this protocol

class DoableImpl: Doable {
    func doSomething() -> Int {
        // some implementation
    }

    func doSomethingWithArgs(x: Int, y: Int) -> Int {
        // some implementation
    }

    func doSomethingReactive(x: Int) -> SignalProducer<Int, NoError> {
        // some implementation
    }
}

// And this protocol is used somewhere

class DoableUsage {
    let doable: Doable

    init(doable: Doable) {
        self.doable = doable
    }

    func useSimpleDoable() -> Int {
        return doable.doSomething()
    }

    func useDoableWithArgs() {
        return doable.doSomethingWithArgs(4, y: 2)
    }

    func useReactiveDoable() -> SignalProducer<Int, NoError> {
        return doable.doSomethingReactive(42)
    }
}

// So now you want to test how Doable is used as a dependency
// You create test class as implementation of Doable protocol
// And create fake calls for each method you want to test

class DoableTest: Doable {
    let doSomethingCall = FunctionVoidCall<Int>()
    func doSomething() -> Int {
        return stubCall(doSomethingCall, defaultValue: 0)
    }

    let doSomethingWithArgsCall = FunctionCall<(x: Int, y: Int), Int>()
    func doSomethingWithArgs(x: Int, y: Int) -> Int {
        return stubCall(doSomethingWithArgsCall, argument: (x: x, y: y), defaultValue: 0)
    }

    let doSomethingReactiveCall = ReactiveCall<Int, Int, NoError>()
    func doSomethingReactive(x: Int) -> SignalProducer<Int, NoError> {
        return stubCall(doSomethingReactiveCall, argument: x)
    }
}

// Now you can use DoableTest in spec to verify its usage

class DoableUsageSpec: QuickSpec {
    override func spec() {
        describe("DoableUsage") {
            var sut: DoableUsage!
            var doable: DoableTest!

            beforeEach {
               doable = DoableTest()
               sut = DoableUsage(doable)
            }

            describe("when using simple doable") {
                beforeEach {
                    doable.doSomethingCall.returns(42)
                }

                it("should ask doable to do something and use its result") {
                    let result = sut.useSimpleDoable()

                    expect(doable.doSomethingCall.called).to(beTruthy())
                    expect(result).to(equal(42))
                }
            }

            describe("when using doable with args") {
                it("should ask doable to do something with 4 and 2") {
                    sut.useDoableWithArgs()
                    // here result of this call will be `0` as we specified it as a `defaultValue` in stubbed Call
                    // we can override it with our custom value as we did in spec above by using `returns` method

                    expect(doable.doSomethingWithArgsCall.capturedArgument?.x).to(equal(4))
                    expect(doable.doSomethingWithArgsCall.capturedArgument?.y).to(equal(2))
                }
            }

            describe("when using reactive doable") {
                it("should ask doable to do something reactive with 42") {
                    sut.useReactiveDoable().start()

                    expect(doable.doSomethingReactiveCall.capturedArgument).to(equal(42))
                }

                context("with successful result") {
                    beforeEach {
                        doable.doSomethingReactiveCall.returns(4422)
                    }

                    it("should use its successful result") {
                        var result: Int!
                        sut.useReactiveDoable().startWithNext { result = $0  }

                        expect(result).to(equal(4422))
                    }
                }
                context("with failure") {
                    enum CustomError: ErrorType { case Error }

                    beforeEach {
                        doable.doSomethingReactiveCall.fails(CustomError.Error)
                    }

                    it("should use its failure result") {
                        var error: ErrorType!
                        sut.useReactiveDoable().startWithFailure { error = $0  }

                        expect(error as NSError).to(equal(CustomError.Error as NSError))
                    }
                }
            }
        }
    }
}

```
