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
    
    // Stubbing Call with predefined Value
    public private(set) var stubbedValue: Value?
    public func returns(value: Value) {
        stubbedValue = value
    }
    
    // Stubbing Call with prefefined logic
    public private(set) var stubbedBlock: (Arg -> Value)?
    public func performs(block: Arg -> Value) {
        stubbedBlock = block
    }
    
    public private(set) var capturedArguments: [Arg] = []
    public var capturedArgument: Arg? {
        return capturedArguments.last
    }
    
    private var stubbedBlocks: [ReturnStub<Arg, Value>] = []
    
    @warn_unused_result(message="Did you forget to call returns?")
    public func on(filter: Arg -> Bool) -> ReturnContext<Arg, Value> {
        let stub = ReturnStub<Arg, Value>(filter: filter)
        stubbedBlocks += [stub]
        return ReturnContext(call: self, stub: stub)
    }
    
    public init() {}
}

public func stubCall<Arg, Value>(call: FunctionCall<Arg, Value>, argument: Arg, defaultValue: Value? = nil)  -> Value {
    call.callsCount += 1
    call.capturedArguments += [argument]
    
    for stub in call.stubbedBlocks {
        if stub.filter(argument) {
            if case let .Some(stubbedBlock) = stub.stubbedBlock {
                return stubbedBlock(argument)
            }

            if case let .Some(stubbedValue) = stub.stubbedValue {
                return stubbedValue
            }
        }
    }

    if case let .Some(stubbedBlock) = call.stubbedBlock {
        return stubbedBlock(argument)
    }
    
    if case let .Some(stubbedValue) = call.stubbedValue {
        return stubbedValue
    }
    if case let .Some(defaultValue) = defaultValue {
        return defaultValue
    }

    assertionFailure("stub doesnt' have value to return")
    
    return call.stubbedValue!
}

// MARK: Helpers for stubbing

public class ReturnContext<Arg, Value> {
    let call: FunctionCall<Arg, Value>
    let stub: ReturnStub<Arg, Value>
    init(call: FunctionCall<Arg, Value>, stub: ReturnStub<Arg, Value>) {
        self.call = call
        self.stub = stub
    }
    
    public func returns(value: Value) -> FunctionCall<Arg, Value> {
        stub.stubbedValue = value
        return call
    }
    
    public func performs(block: (Arg -> Value)) -> FunctionCall<Arg, Value> {
        stub.stubbedBlock = block
        return call
    }
}

public class ReturnStub<Arg, Value> {
    let filter: Arg -> Bool
    private(set) var stubbedValue: Value?
    private(set) var stubbedBlock: (Arg -> Value)?
    
    init(filter: Arg -> Bool) {
        self.filter = filter
    }
}

// MARK: Function Call Mock/Stub/Spy Without Arguments

public class FunctionVoidCall<Value>: FunctionCall<Void, Value> {
    public override init() {
        super.init()
    }
}

public func stubCall<Value>(call: FunctionCall<Void, Value>, defaultValue: Value? = nil) -> Value {
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
