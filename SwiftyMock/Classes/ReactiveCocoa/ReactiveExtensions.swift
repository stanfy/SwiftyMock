// A handy Utility for manual function calls testing.
// Since Swift doesn't provide any access to runtime yet, we have to manually mock, stub and spy our calls

// swiftlint:disable line_length

// MARK: Reactive Function Call Mock/Stub/Spy

import ReactiveSwift
import Result

// MARK: - Reactive Call Mock/Stub/Spy

public typealias ReactiveCall<Arg, Value, Err: Error> = FunctionCall<Arg, Result<Value, Err>>
public typealias ReactiveVoidCall<Value, Err: Error> = FunctionVoidCall<Result<Value, Err>>

public typealias ReactiveEventsCall<Arg, Value, Err: Error> = FunctionCall<Arg, [Signal<Value, Err>.Event]>
public typealias ReactiveEventsVoidCall<Value, Err: Error> = FunctionVoidCall<[Signal<Value, Err>.Event]>

// Stub Signal Producer Call

public func stubCall<Arg, Value, Err>(_ call: ReactiveCall<Arg, Value, Err>, argument: Arg, defaultValue: Result<Value, Err>? = nil) -> SignalProducer<Value, Err> {

    // returning empty signal producer if no default value provide, thus preventing failure assert
    if call.stubbedBlocks.isEmpty && call.stubbedBlock == nil && call.stubbedValue == nil && defaultValue == nil {
        call.capture(argument)
        return .empty
    }

    // otherwise - just repeating normal function stubbing flow
    let result: Result<Value, Err> = stubCall(call, argument: argument, defaultValue: defaultValue)

    // and returning signal producer depending on result value
    return SignalProducer(result: result)
}

public func stubCall<Arg, Value, Err>(_ call: ReactiveEventsCall<Arg, Value, Err>, argument: Arg, defaultEvents: [Signal<Value, Err>.Event] = []) -> SignalProducer<Value, Err> {

    // returning empty signal producer if no default value provide, thus preventing failure assert
    if call.stubbedBlocks.isEmpty && call.stubbedBlock == nil && call.stubbedValue == nil && defaultEvents.isEmpty {
        call.capture(argument)
        return .empty
    }

    // otherwise - duplicate normal function stubbing flow
    call.capture(argument)

    // and returning signal producer by sending all events
    return SignalProducer { (observer, lifetime) in
        // we're sending completed event in case array of events doesn't contain one of event that completes signal: (interrupted | completed | failed)
        // if there's one of such events, observer won't send another one completing event, thus nothing will happen
        defer { observer.sendCompleted() }

        for stub in call.stubbedBlocks {
            if stub.filter(argument) {
                if case let .some(stubbedBlock) = stub.stubbedBlock {
                    return stubbedBlock(argument).forEach(observer.send)
                }

                if case let .some(stubbedValue) = stub.stubbedValue {
                    return stubbedValue.forEach(observer.send)
                }
            }
        }

        if case let .some(stubbedBlock) = call.stubbedBlock {
            return stubbedBlock(argument).forEach(observer.send)
        }

        if case let .some(stubbedValue) = call.stubbedValue {
            return stubbedValue.forEach(observer.send)
        }

        if !defaultEvents.isEmpty {
            return defaultEvents.forEach(observer.send)
        }

        assertionFailure("stub doesnt' have events to send")

        return call.stubbedValue!.forEach(observer.send)
    }
}

// MARK: - Function Call Mock/Stub/Spy Without Arguments

public func stubCall<Value, Err>(_ call: ReactiveVoidCall<Value, Err>, defaultValue: Result<Value, Err>? = nil) -> SignalProducer<Value, Err> {
    return stubCall(call, argument: (), defaultValue: defaultValue)
}

public func stubCall<Value, Err>(_ call: ReactiveEventsVoidCall<Value, Err>, defaultEvents: [Signal<Value, Err>.Event] = []) -> SignalProducer<Value, Err> {
    return stubCall(call, argument: (), defaultEvents: defaultEvents)
}

// MARK: - Stub Action Call

public func stubCall<Value, Err>(_ call: ReactiveVoidCall<Value, Err>, defaultValue: Result<Value, Err>? = nil) -> Action<Void, Value, Err> {
    return Action {
        stubCall(call, defaultValue: defaultValue)
    }
}
