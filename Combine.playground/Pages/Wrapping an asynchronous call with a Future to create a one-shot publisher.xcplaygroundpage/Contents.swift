//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import Combine
PlaygroundPage.current.needsIndefiniteExecution = true

/**
 Goal
 • Using Future to turn an asynchronous call into publisher to use the result in a Combine pipeline.
 */

import Contacts
let futureAsyncPublisher = Future<Bool, Error> { promise in
    CNContactStore().requestAccess(for: .contacts) { grantedAccess, err in
        if let err = err {
            promise(.failure(err))
        }
        return promise(.success(grantedAccess))
    }
}.eraseToAnyPublisher()


let resolvedSuccessAsPublisher = Future<Bool, Error> { promise in
    promise(.success(true))
}.eraseToAnyPublisher()


let cancellableSink = resolvedSuccessAsPublisher
    .sink(receiveCompletion: { completion in
        print(".sink() received the completion", String(describing: completion))
        switch completion {
        case .finished:
            break
        case .failure(let anError):
            print("received error: ", anError)
        }
    }, receiveValue: { someValue in
        print(".sink() received \(someValue)")
    })

//: [Next](@next)
