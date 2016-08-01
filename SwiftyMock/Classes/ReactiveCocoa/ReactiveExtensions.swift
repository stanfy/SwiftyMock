// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: Reactive Function Call Mock/Stub/Spy

import ReactiveCocoa

public class ReactiveCall<Arg, Value, Error: ErrorType>: FunctionCall<Arg, Value> {
    public private(set) var stubbedError: Error?
    public func fails(error: Error) {
        stubbedError = error
    }
    
    public override init() {
        super.init()
    }
}

// Stub Signal Producer Call

public func stubCall<Arg, Value, Error: ErrorType>(call: ReactiveCall<Arg, Value, Error>, argument: Arg) -> SignalProducer<Value, Error> {
    call.callsCount += 1
    call.capturedArguments += [argument]
    
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

public class ReactiveVoidCall<Value, Error: ErrorType>: ReactiveCall<Void, Value, Error> {
    public override init() {
        super.init()
    }
}

public func stubCall<Value, Error: ErrorType>(call: ReactiveCall<Void, Value, Error>) -> SignalProducer<Value, Error> {
    return stubCall(call, argument: ())
}

// Stub Action Call

public func stubCall<Value, Error: ErrorType>(call: ReactiveCall<Void, Value, Error>) -> Action<Void, Value, Error> {
    return Action {
        stubCall(call)
    }
}
