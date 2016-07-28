// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: Function Call Mock/Stub/Spy

public class FunctionCall<Arg, Value> {
    
    // Spying Call's passed Arguments
    
    public private(set) var callsCount: Int = 0
    public var called: Bool {
        return callsCount > 0
    }
    
    public private(set) var capturedArguments: [Arg] = []
    public var capturedArgument: Arg? {
        return capturedArguments.last
    }
    
    // Stubbing Call with predefined Value
    
    public private(set) var stubbedValue: Value?
    public func returns(value: Value) -> FunctionCall<Arg, Value>  {
        stubbedValue = value
        return self
    }
    
    private var stubbedBlocks: [Arg -> (Bool, Value?)] = []
    public func returns(value: Value?, when filter: Arg -> Bool) -> FunctionCall<Arg, Value> {
        stubbedBlocks += [{ (filter($0), value) }]
        return self
    }
    
    public init() {}
}

public func stubCall<Arg, Value>(call: FunctionCall<Arg, Value>, argument: Arg, defaultValue: Value) -> Value {
    call.callsCount += 1
    call.capturedArguments += [argument]
    
    for stub in call.stubbedBlocks {
        let result = stub(argument)
        if result.0 {
            if case let .Some(stubbedValue) = result.1 {
                return stubbedValue
            }
        }
    }
    
    guard let stubbedValue = call.stubbedValue else { return defaultValue  }
    
    return stubbedValue
}

// MARK: Function Call Mock/Stub/Spy Without Arguments

public class FunctionVoidCall<Value>: FunctionCall<Void, Value> {
    public override init() {
        super.init()
    }
}

public func stubCall<Value>(call: FunctionCall<Void, Value>, defaultValue: Value) -> Value {
    return stubCall(call, argument: (), defaultValue: defaultValue)
}

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
