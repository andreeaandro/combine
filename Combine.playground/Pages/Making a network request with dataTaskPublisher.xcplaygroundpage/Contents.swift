//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/**
 Goal
 • One of the common use cases is requesting JSON data from a URL and decoding it.
 */

let myURL = URL(string: "https://postman-echo.com/time/valid?timestamp=2016-10-10")
// checks the validity of a timestamp - this one returns {"valid":true}


// matching the data structure returned from https://postman-echo.com/time/valid
struct PostmanEchoTimeStampCheckResponse: Decodable, Hashable {
    let valid: Bool
}


let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: myURL!)
    // the dataTaskPublisher output combination is (data: Data, response: URLResponse)
    .map { $0.data }
    .decode(type: PostmanEchoTimeStampCheckResponse.self, decoder: JSONDecoder())

let cancellableSink = remoteDataPublisher
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
