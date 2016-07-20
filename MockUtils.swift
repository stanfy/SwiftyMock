//
// Created by Paul Taykalo on 6/30/16.
// Copyright (c) 2016 CocoaPods. All rights reserved.
//

import Foundation
import Result
import ReactiveCocoa

public class Call<S, F: ErrorType> {
    public var callsCount: Int = 0
    public var called: Bool {
        return callsCount > 0
    }
    public var stub: Result<S, F>?
    public func will(stub: Result<S, F>) {
        self.stub = stub
    }
    public init() {}
}

public class FunctionCall<P, S>: Call<S, NoError> {
    public var capturedValues: [P] = []
    public var capturedValue: P? {
        return capturedValues.last
    }
    public override init() { super.init() }
}

public func stubCall<S, F>(call: Call<S, F>) -> SignalProducer<S, F> {
    call.callsCount += 1
    if case let .Some(.Failure(error)) = call.stub {
        return SignalProducer(error: error)
    }
    if case let .Some(.Success(value)) = call.stub {
        return SignalProducer(value: value)
    }
    return .empty
}

public func stubCall<S, P>(call: FunctionCall<P, S>, parameter: P, defaultValue: S) -> S {
    call.callsCount += 1
    call.capturedValues += [parameter]
    if case let .Some(.Success(stubbedValue)) = call.stub {
        return stubbedValue
    }
    return defaultValue
}

public func stubCall<S, F>(call: Call<S, F>) -> Action<(), S, F> {
    return Action {
        return stubCall(call)
    }
}
