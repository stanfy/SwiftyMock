// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: Reactive Function Call Mock/Stub/Spy

import ReactiveSwift

open class ReactiveCall<Arg, Value, Err: Error>: FunctionCall<Arg, Value> {
    open fileprivate(set) var stubbedError: Err?
    open func fails(_ error: Err) {
        stubbedError = error
    }
    
    public override init() {
        super.init()
    }
}

// Stub Signal Producer Call

public func stubCall<Arg, Value, Err: Error>(_ call: ReactiveCall<Arg, Value, Err>, argument: Arg) -> SignalProducer<Value, Err> {
    call.capture(argument)
    
    // Value presence has higher priority over error
    // If both Value and Error set, then Value is chosen
    
    if let value = call.stubbedValue {
        return SignalProducer(value: value)
    }
    
    if let error = call.stubbedError {
        return SignalProducer(error: error)
    }
    
    return .empty
}

// MARK: Reactive Function Call Mock/Stub/Spy Without Arguments

open class ReactiveVoidCall<Value, Err: Error>: ReactiveCall<Void, Value, Err> {
    public override init() {
        super.init()
    }
}

public func stubCall<Value, Err: Error>(_ call: ReactiveCall<Void, Value, Err>) -> SignalProducer<Value, Err> {
    return stubCall(call, argument: ())
}

// Stub Action Call

public func stubCall<Value, Err: Error>(_ call: ReactiveCall<Void, Value, Err>) -> Action<Void, Value, Err> {
    return Action {
        stubCall(call)
    }
}
