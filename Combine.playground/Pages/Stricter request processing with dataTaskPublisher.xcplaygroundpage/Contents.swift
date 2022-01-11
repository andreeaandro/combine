//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import Combine
PlaygroundPage.current.needsIndefiniteExecution = true

/**
 Goal
 • When URLSession makes a connection, it only reports an error if the remote server doesn’t respond. You may want to consider a number of responses, based on status code, to be errors. To accomplish this, you can use tryMap to inspect the http response and throw an error in the pipeline.
 */

enum APIError: Error, LocalizedError {
    case unknown
    case apiError(reason: String)
    case parserError(reason: String)
    case networkError(from: URLError)
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}

func fetch(url: URL) -> AnyPublisher<Data, APIError> {
    let request = URLRequest(url: url)
    return URLSession.DataTaskPublisher(request: request, session: .shared)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            if (httpResponse.statusCode == 401) {
                throw APIError.apiError(reason: "Unauthorized")
            }
            
            if (httpResponse.statusCode == 403) {
                throw APIError.apiError(reason: "Resource forbidden")
            }
            
            if (httpResponse.statusCode == 404) {
                throw APIError.apiError(reason: "Resource not found")
            }
            
            if (405..<500 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "client error")
            }
            
            if (500..<600 ~= httpResponse.statusCode) {
                throw APIError.apiError(reason: "server error")
            }
            
            return data
        }
        .mapError { error in
            // if it's our kind of error already, we can return it directly
            if let error = error as? APIError {
                return error
            }
            
            // if it is a URLError, we can convert it into our more general error kind
            if let urlerror = error as? URLError {
                return APIError.networkError(from: urlerror)
            }
            
            // if all else fails, return the unknown error condition
            return APIError.unknown
        }
        .eraseToAnyPublisher()
    }

let myURL = URL(string: "https://postman-echo.com/time/valid?timestamp=2016-10-10")!

let cancellableSink = fetch(url: myURL)
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
