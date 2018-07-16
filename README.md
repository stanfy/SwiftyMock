# SwiftyMock [![Build Status](https://travis-ci.org/stanfy/SwiftyMock.svg?branch=master)](https://travis-ci.org/stanfy/SwiftyMock)

This repository contains helpers that make mocking, stubbing and spying in Swift much easier

# Example

## Protocol 
Imagine you have some protocol that describes some behaviour

```swift
protocol RoboKitten {
    func batteryStatus() -> Int
    func jump(x x: Int, y: Int) -> Int
    func canJumpAt(x x: Int, y: Int) -> Bool
    func rest(completed: Bool -> () )
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

    let jumpCall = FunctionCall<(x: Int, y: Int), Int>()
    func jump(x x: Int, y: Int) -> Int {
        return stubCall(jumpCall, argument: (x: x, y: y))
    }
    
    let canJumpAtCall = FunctionCall<(x: Int, y: Int), Bool>()
    func canJumpAt(x x: Int, y: Int) -> Bool {
        return stubCall(canJumpAtCall, argument: (x: x, y: y))
    }

    let restCall = FunctionCall<Bool -> (), ()>()
    func rest(completed: Bool -> ()) {
        return stubCall(restCall, argument: completed, defaultValue: ())
    }
}
```

## Mock usage
If setup was correct it's really easy to specify mock behaviour by using subbed methods

### Method stub
Let's say we want to our mock to return some values  
It's really easy
```swift
// like this
kittenMock.canJumpAtCall.returns(false)

// or like this
kittenMock.jumpCall.returns(20)
```

Sometimes, you have bit more complex rules when and what to return   
```swift
// You can add as many filters you like
// More specific rules overrides general rules
kittenMock.canJumpAtCall
    .on { $0.x < 0 }.returns(false)
    .on { $0.y < 0 }.returns(false)
    .returns(true) // in all other cases
    
```    

And sometimes you need even more complex mock behaviour, when you need for example to pass closures into mock
```swift
protocol RoboKitten {
    func rest(completed: Bool -> () )
}

kittenMock.restCall.performs { completion in
    print("Mock method was called! Remove this in prod version:))")
    completion(true)
}
```

### Method call check
Also from time to time, you need to be sure that method was called  
```swift
beforeEach {
    // Since canjump method need to return somtehing we need to specify return value
    kittenMock.canJumpAtCall.returns(false)
}
it("should ask kitten if it's available to jump there") {
    sut.jumpAt(x: 10, y: 20)
    expect(kittenMock.canJumpAtCall.called).to(beTruthy())
}
```

Or you need to check that method was called exact number of times
```swift
it("should actually ask kitten to jump only once per call") {
    sut.jumpAt(x: 18, y: 23)
    expect(kittenMock.jumpCall.callsCount).to(equal(1))
    
    sut.jumpAt(x: 80, y: 15)
    expect(kittenMock.jumpCall.callsCount).to(equal(2))
}
```

All method calls are stored in the mock, so you can easily check if mock was called with correct parameters
```swift
it("should ask kitten if it's available to jump there with the same coords") {
    sut.jumpAt(x: 10, y: 20)
    expect(kittenMock.canJumpAtCall.capturedArgument?.x).to(equal(10))
    expect(kittenMock.canJumpAtCall.capturedArgument?.y).to(equal(20))
}
```

## [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) stubs support
API for methods that return `SignalProducer` or `Action` is pretty much the same as for usual methods stubs.

Imagine RoboKitten protocol is a bit changed and returns SignalProducer instead of plain value, so we can keep and eye on battery status level.

```swift
protocol RoboKitten {
    func batteryStatus() -> SignalProducer<Int, NoError>
}
```

Now you create mock implementation of this protocol, but instead of `FunctionCall`, you're using `ReactiveCall`.
The only difference is that we've added third type constraint to specify `Error`.

```swift
class RoboKittenMock: RoboKitten {
    let batteryStatusCall = ReactiveCall<(), Int, NoError>()
    func batteryStatus() -> SignalProducer<Int, NoError> {
        return stubCall(batteryStatusCall, argument:())
    }
}
```

### Method stub
Since `SignalProducer` is constrained by **Value** and **Error** types, we need to allow user to choose, which one to stub call with.
Luckily there's handy [Result](https://github.com/antitypical/Result) type and its implementation comes along with [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift).
Thus in order to stub `ReactiveCall`, you use `Result` instead of plain value as you did with `FunctionCall`.

```swift
// like this
kittenMock.batteryStatusCall.returns(.success(42))
// or
kittenMock.batteryStatusCall.returns(Result(value: 42))

// or in case you want this stub to return failure
kittenMock.batteryStatusCall.returns(.failure(ImagineThisIsError))
// or
kittenMock.batteryStatusCall.returns(Result(error: ImagineThisIsError))
```

Everything else stays the same :)

# Matchers
SwiftyMock doesn't have its own matchers, so you can use whatever matchers suits better for you :)

# Templates
You can generate mocks automatically with [Sourcery](https://github.com/krzysztofzablocki/Sourcery).    
First, create sourcery config yml and specify paths to sources, templates, generated output and testable import framework for tests.
You can take a look at how `.sourcery.yml` here in the root looks like.
```yml
sources: 
  - ./Example/SwiftyMock/RoboKitten
templates: 
  - ./SwiftyMock/Templates
output:
  path: ./Example/RoboKittenTests/Mocks/Generated
args:
  testable: SwiftyMock_Example # here you specify your application module name, that you're importing for testing
```
Second, annotate protocols that you want to generate mocks for, with `// sourcery: Mock` comment:
```swift
// sourcery: Mock
protocol RoboKitten {
    // ...
}
```
Third, run sourcery command `sourcery --config .sourcery.yml --watch` if you want to run service that will regenerate mocks every time your source files or templates change.   
Or `sourcery --config .sourcery.yml` if you want to generate mocks once.
