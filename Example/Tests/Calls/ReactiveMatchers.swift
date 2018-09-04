//
//  ReactiveMatchers.swift
//  SwiftyMock_Example
//
//  Created by Alexander Voronov on 11/23/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Result
import ReactiveSwift

// MARK: - Send Value

private func sendValue<T: SignalProducerConvertible, V, E>(
    where predicate: @escaping (V) -> Bool,
    expectation: @escaping (Signal<V, E>.Event?, V?) -> ExpectationMessage
) -> Predicate<T> where T.Value == V, T.Error == E {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        var actualEvent: Signal<V, E>.Event?
        var actualValue: V?
        var satisfies: Bool = false
        let actualProducer = try actualExpression.evaluate()
        actualProducer?.producer.start { event in
            actualEvent = event
            if case let .value(value) = event {
                actualValue = value
                satisfies = predicate(value)
            }
        }
        guard actualValue != nil else {
            return PredicateResult(
                status: .fail,
                message: expectation(actualEvent, actualValue)
            )
        }
        return PredicateResult(
            bool: satisfies,
            message: expectation(actualEvent, actualValue)
        )
    }
}

func sendValue<T: SignalProducerConvertible, V>(where predicate: @escaping (V) -> Bool) -> Predicate<T> where T.Value == V {
    return sendValue(where: predicate, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value to satisfy predicate",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

func sendValue<T: SignalProducerConvertible, V: Equatable>(_ expectedValue: V) -> Predicate<T> where T.Value == V {
    return sendValue(where: { $0 == expectedValue }, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value <\(stringify(expectedValue))>",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

func sendEmptyValue<T: SignalProducerConvertible>() -> Predicate<T> where T.Value == Void {
    return sendValue(where: { true }, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value <Void>",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

// MARK: - Send Value and Complete

private func sendValueAndComplete<T: SignalProducerConvertible, V, E>(
    where predicate: @escaping (V) -> Bool,
    expectation: @escaping (Signal<V, E>.Event?, V?) -> ExpectationMessage
) -> Predicate<T> where T.Value == V, T.Error == E {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        var actualEvent: Signal<V, E>.Event?
        var completed: Bool = false
        var actualValue: V?
        var satisfies: Bool = false
        let actualProducer = try actualExpression.evaluate()
        actualProducer?.producer.start { event in
            actualEvent = event
            if case let .value(value) = event {
                actualValue = value
                satisfies = predicate(value)
            }
            if case .completed = event {
                completed = true
            } else {
                completed = false
            }
        }
        guard actualValue != nil, completed else {
            return PredicateResult(
                status: .fail,
                message: expectation(actualEvent, actualValue)
            )
        }
        return PredicateResult(
            bool: satisfies,
            message: expectation(actualEvent, actualValue)
        )
    }
}

func sendValueAndComplete<T: SignalProducerConvertible, V>(where predicate: @escaping (V) -> Bool) -> Predicate<T> where T.Value == V {
    return sendValueAndComplete(where: predicate, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value to satisfy predicate and complete",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

func sendValueAndComplete<T: SignalProducerConvertible, V: Equatable>(_ expectedValue: V) -> Predicate<T> where T.Value == V {
    return sendValue(where: { $0 == expectedValue }, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value <\(stringify(expectedValue))> and complete",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

func sendEmptyValueAndComplete<T: SignalProducerConvertible>() -> Predicate<T> where T.Value == Void {
    return sendValue(where: { true }, expectation: { (actualEvent, actualValue) in
        .expectedCustomValueTo(
            "send value <Void> and complete",
            message(forEvent: actualEvent, value: actualValue)
        )
    })
}

// MARK: - Complete

func complete<T: SignalProducerConvertible, V, E>() -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvent(where: { $0.isCompleted }, expectation: { actualEvent in
        .expectedCustomValueTo(
            "complete",
            message(forEvent: actualEvent)
        )
    })
}

// MARK: - Fail

private func fail<T: SignalProducerConvertible, V, E>(
    where predicate: @escaping (E) -> Bool,
    expectation: @escaping (Signal<V, E>.Event?, E?) -> ExpectationMessage
) -> Predicate<T> where T.Value == V, T.Error == E {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        var actualEvent: Signal<V, E>.Event?
        var actualError: E?
        var matches: Bool = false
        let actualProducer = try actualExpression.evaluate()
        actualProducer?.producer.start { event in
            actualEvent = event
            if case let .failed(error) = event {
                actualError = error
                matches = predicate(error)
            }
        }
        guard actualError != nil else {
            return PredicateResult(
                status: .fail,
                message: expectation(actualEvent, actualError)
            )
        }
        return PredicateResult(
            bool: matches,
            message: expectation(actualEvent, actualError)
        )
    }
}

func fail<T: SignalProducerConvertible, E>(where predicate: @escaping (E) -> Bool) -> Predicate<T> where T.Error == E {
    return fail(where: predicate, expectation: { (actualEvent, actualError) in
        .expectedCustomValueTo(
            "send error to satisfy predicate",
            message(forEvent: actualEvent, error: actualError)
        )
    })
}

func fail<T: SignalProducerConvertible, E>(with expectedError: E) -> Predicate<T> where T.Error == E {
    return fail(where: { errorMatchesExpectedError($0, expectedError: expectedError) }, expectation: { (actualEvent, actualError) in
        .expectedCustomValueTo(
            "send error <\(stringify(expectedError))>",
            message(forEvent: actualEvent, error: actualError)
        )
    })
}

func fail<T: SignalProducerConvertible, E: Equatable>(with expectedError: E) -> Predicate<T> where T.Error == E {
    return fail(where: { $0 == expectedError }, expectation: { (actualEvent, actualError) in
        .expectedCustomValueTo(
            "send error <\(stringify(expectedError))>",
            message(forEvent: actualEvent, error: actualError)
        )
    })
}

func failWithNoError<T: SignalProducerConvertible>() -> Predicate<T> where T.Error == NoError {
    return fail(where: { _ in true }, expectation: { (actualEvent, actualError) in
        .expectedCustomValueTo(
            "send error <NoError>",
            message(forEvent: actualEvent, error: actualError)
        )
    })
}

// MARK: - Interrupt

func interrupt<T: SignalProducerConvertible, V, E>() -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvent(where: { $0.isInterrupted }, expectation: { actualEvent in
        .expectedCustomValueTo(
            "interrupt",
            message(forEvent: actualEvent)
        )
    })
}

// MARK: - Event

private func sendEvent<T: SignalProducerConvertible, V, E>(
    where predicate: @escaping (Signal<V, E>.Event) -> Bool,
    expectation: @escaping (Signal<V, E>.Event?) -> ExpectationMessage
) -> Predicate<T> where T.Value == V, T.Error == E {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        var actualEvent: Signal<V, E>.Event?
        var satisfies: Bool = false
        let actualProducer = try actualExpression.evaluate()
        actualProducer?.producer.start { event in
            actualEvent = event
            satisfies = predicate(event)
        }
        return PredicateResult(
            bool: satisfies,
            message: expectation(actualEvent)
        )
    }
}

func sendEvent<T: SignalProducerConvertible, V, E>(where predicate: @escaping (Signal<V, E>.Event) -> Bool) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvent(where: predicate, expectation: { actualEvent in
        .expectedCustomValueTo(
            "send event to satisfy predicate",
            message(forEvent: actualEvent)
        )
    })
}

func sendEvent<T: SignalProducerConvertible, V: Equatable, E: Equatable>(_ expectedEvent: Signal<V, E>.Event) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvent(where: { $0 == expectedEvent }, expectation: { actualEvent in
        .expectedCustomValueTo(
            "send " + message(forEvent: expectedEvent),
            message(forEvent: actualEvent)
        )
    })
}

// MARK: - Events

private func sendEvents<T: SignalProducerConvertible, V, E>(
    where predicate: @escaping ([Signal<V, E>.Event]) -> Bool,
    expectation: @escaping ([Signal<V, E>.Event]) -> ExpectationMessage
) -> Predicate<T> where T.Value == V, T.Error == E {
    return Predicate { (actualExpression: Expression<T>) throws -> PredicateResult in
        var actualEvents: [Signal<V, E>.Event] = []
        var satisfies: Bool = false
        let actualProducer = try actualExpression.evaluate()
        actualProducer?.producer
            .on(event: { event in
                actualEvents.append(event)
            })
            .on(terminated: {
                satisfies = predicate(actualEvents)
            })
            .start()
        return PredicateResult(
            bool: satisfies,
            message: expectation(actualEvents)
        )
    }
}

func sendEvents<T: SignalProducerConvertible, V, E>(where predicate: @escaping ([Signal<V, E>.Event]) -> Bool) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvents(where: predicate, expectation: { actualEvents in
        .expectedCustomValueTo(
            "send events to satisfy predicate",
            message(forEvents: actualEvents)
        )
    })
}

func sendEvents<T: SignalProducerConvertible, V: Equatable, E: Equatable>(_ expectedEvents: [Signal<V, E>.Event]) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvents(where: { $0 == expectedEvents }, expectation: { actualEvents in
        .expectedCustomValueTo(
            "send " + message(forEvents: expectedEvents),
            message(forEvents: actualEvents)
        )
    })
}

func sendEvents<T: SignalProducerConvertible, V, E>(whereAll predicate: @escaping (Signal<V, E>.Event) -> Bool) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvents(where: { events in !events.contains(where: { !predicate($0) }) }, expectation: { actualEvents in
        .expectedCustomValueTo(
            "send all events to satisfy predicate",
            message(forEvents: actualEvents)
        )
    })
}

func sendEvents<T: SignalProducerConvertible, V, E>(whereAny predicate: @escaping (Signal<V, E>.Event) -> Bool) -> Predicate<T> where T.Value == V, T.Error == E {
    return sendEvents(where: { events in events.contains(where: predicate) }, expectation: { actualEvents in
        .expectedCustomValueTo(
            "send at least one event to satisfy predicate",
            message(forEvents: actualEvents)
        )
    })
}

// MARK: - Helpers

fileprivate extension Signal.Event {
    var isInterrupted: Bool {
        if case .interrupted = event { return true }
        return false
    }
}

extension Signal.Event: Equatable where Signal.Value: Equatable, Signal.Error: Equatable {}

fileprivate func errorMatchesExpectedError<T: Error>(_ actualError: Error, expectedError: T) -> Bool {
    return actualError._domain == expectedError._domain
        && actualError._code   == expectedError._code
}

fileprivate func message<V, E>(forEvents events: [Signal<V, E>.Event]?) -> String {
    if let events = events {
        let stringifiedEvents = events.map(stringify).joined(separator: ", ")
        return "<[\(stringifiedEvents)]> events"
    }
    return "no events"
}

fileprivate func message<V, E>(forEvent event: Signal<V, E>.Event?) -> String {
    if let event = event {
        return "<\(stringify(event))> event"
    }
    return "no event"
}

fileprivate func message<V, E>(forEvent event: Signal<V, E>.Event?, value: V?) -> String {
    if let event = event {
        if case .value = event {
            return "<\(stringify(value))> value"
        }
        return "<\(stringify(event))> event with <\(stringify(value))> value"
    }
    return "no event"
}

fileprivate func message<V, E>(forEvent event: Signal<V, E>.Event?, error: E?) -> String {
    if let event = event {
        if case .failed = event {
            return "<\(stringify(error))> error"
        }
        return "<\(stringify(event))> event with <\(stringify(error))> error"
    }
    return "no event"
}
