// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: - Function Call Mock/Stub/Spy

open class FunctionCall<Arg, Value> {

    // Spying Call's passed Arguments

    open fileprivate(set) var callsCount: Int = 0
    open var called: Bool {
        return callsCount > 0
    }

    // Stubbing Call with predefined Value
    open fileprivate(set) var stubbedValue: Value?
    open func returns(_ value: Value) {
        stubbedValue = value
    }

    // Stubbing Call with prefefined logic
    open fileprivate(set) var stubbedBlock: ((Arg) -> Value)?
    open func performs(_ block: @escaping (Arg) -> Value) {
        stubbedBlock = block
    }

    open fileprivate(set) var capturedArguments: [Arg] = []
    open var capturedArgument: Arg? {
        return capturedArguments.last
    }

    fileprivate(set) var stubbedBlocks: [ReturnStub<Arg, Value>] = []

    open func on(_ filter: @escaping (Arg) -> Bool) -> ReturnContext<Arg, Value> {
        let stub = ReturnStub<Arg, Value>(filter: filter)
        stubbedBlocks += [stub]
        return ReturnContext(call: self, stub: stub)
    }

    public init() {}

    func capture(_ argument: Arg) {
        callsCount += 1
        capturedArguments += [argument]
    }
}

public func stubCall<Arg, Value>(_ call: FunctionCall<Arg, Value>, argument: Arg, defaultValue: Value? = nil)  -> Value {
    call.capture(argument)
    
    for stub in call.stubbedBlocks {
        if stub.filter(argument) {
            if case let .some(stubbedBlock) = stub.stubbedBlock {
                return stubbedBlock(argument)
            }

            if case let .some(stubbedValue) = stub.stubbedValue {
                return stubbedValue
            }
        }
    }

    if case let .some(stubbedBlock) = call.stubbedBlock {
        return stubbedBlock(argument)
    }

    if case let .some(stubbedValue) = call.stubbedValue {
        return stubbedValue
    }

    if case let .some(defaultValue) = defaultValue {
        return defaultValue
    }

    assertionFailure("stub doesnt' have value to return")

    return call.stubbedValue!
}

// MARK: - Helpers for stubbing

open class ReturnContext<Arg, Value> {
    let call: FunctionCall<Arg, Value>
    let stub: ReturnStub<Arg, Value>
    init(call: FunctionCall<Arg, Value>, stub: ReturnStub<Arg, Value>) {
        self.call = call
        self.stub = stub
    }

    @discardableResult open func returns(_ value: Value) -> FunctionCall<Arg, Value> {
        stub.stubbedValue = value
        return call
    }

    @discardableResult open func performs(_ block: @escaping ((Arg) -> Value)) -> FunctionCall<Arg, Value> {
        stub.stubbedBlock = block
        return call
    }
}

open class ReturnStub<Arg, Value> {
    let filter: (Arg) -> Bool
    fileprivate(set) var stubbedValue: Value?
    fileprivate(set) var stubbedBlock: ((Arg) -> Value)?

    init(filter: @escaping (Arg) -> Bool) {
        self.filter = filter
    }
}

// MARK: - Function Call Mock/Stub/Spy Without Arguments

public typealias FunctionVoidCall<Value> = FunctionCall<Void, Value>

public func stubCall<Value>(_ call: FunctionVoidCall<Value>, defaultValue: Value? = nil) -> Value {
    return stubCall(call, argument: (), defaultValue: defaultValue)
}
