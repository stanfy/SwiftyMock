// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: Reactive Function Call Mock/Stub/Spy

import ReactiveSwift
import Result

// MARK: - Reactive Call Mock/Stub/Spy

public typealias ReactiveCall<Arg, Value, Err: Error> = FunctionCall<Arg, Result<Value, Err>>
public typealias ReactiveVoidCall<Value, Err: Error> = FunctionCall<Void, Result<Value, Err>>

// Stub Signal Producer Call

public func stubCall<Arg, Value, Err>(_ call: ReactiveCall<Arg, Value, Err>, argument: Arg, defaultValue: Result<Value, Err>? = nil) -> SignalProducer<Value, Err> {

    // returning empty signal producer if no default value provide, thus preventing failure assert
    if defaultValue == nil {
        call.capture(argument)
        return .empty
    }

    // otherwise - just repeating normal function stubbing flow
    let result: Result<Value, Err> = stubCall(call, argument: argument, defaultValue: defaultValue)

    // and returning signal producer depending on result value
    return SignalProducer(result: result)
}

// MARK: - Function Call Mock/Stub/Spy Without Arguments

public func stubCall<Value, Err>(_ call: ReactiveVoidCall<Value, Err>, defaultValue: Result<Value, Err>? = nil) -> SignalProducer<Value, Err> {
    return stubCall(call, argument: (), defaultValue: defaultValue)
}

// MARK: - Stub Action Call

public func stubCall<Value, Err>(_ call: ReactiveVoidCall<Value, Err>, defaultValue: Result<Value, Err>? = nil) -> Action<Void, Value, Err> {
    return Action {
        stubCall(call, defaultValue: defaultValue)
    }
}
