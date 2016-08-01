# SwiftMock [![Build Status](https://travis-ci.org/stanfy/SwiftyMock.svg?branch=master)](https://travis-ci.org/stanfy/SwiftyMock)

This repository contains helpers that make mocking, stubbing and spying in Swift much easier

# Example

## Protocol 
Imagine you have some protocol that describes some behaviour

```swift
protocol RoboKitten {
    func batteryStatus() -> Int
    func jump(x x: Int, y: Int) -> Int
    func canJumpAt(x x: Int, y: Int) -> Bool
}
```

## Protocol usage
And this protocol is used somewhere

```swift
class RoboKittenController {
    let kitten: RoboKitten

    init(kitten: RoboKitten) {
        self.kitten = kitten
    }
    
    func jumpAt(x x: Int, y: Int) -> Result {
        if kitten.canJumpAt(x: x, y: y) {
            kitten.jump(x: x, y: y)
            return .SUCCESS
        }
        return .FAILURE
    }
    ...
}
```
## Protocol mock

So now you want to test how protocol is used as a dependency
And you create to create mock implementation of protocol
And create fake calls for each method you want to test
So here how it will look like in SwiftyMock

```swift
class RoboKittenMock: RoboKitten {
    let batteryStatusCall = FunctionCall<(), Int>()
    func batteryStatus() -> Int {
        return stubCall(batteryStatusCall, argument:())
    }

    let jump = FunctionCall<(x: Int, y: Int), Int>()
    func jump(x x: Int, y: Int) -> Int {
        return stubCall(jump, argument: (x: x, y: y))
    }
    
    let canJump = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x x: Int, y: Int) -> Bool {
        return stubCall(canJump, argument: (x: x, y: y))
    }
}
```

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
