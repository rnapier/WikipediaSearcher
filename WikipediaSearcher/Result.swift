//
//  Result.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

// Work-arounds until we don't need Box
// When that happens, s/success/.Success/; s/.unbox//

func success<A>(value: A) -> Result<A> {
  return .Success(Box(value))
}

func failure<A>(error: NSError) -> Result<A> {
  return .Failure(error)
}

enum Result<A> {
  case Success(Box<A>)
  case Failure(NSError)

  // This idea from http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics
  // Turns out to be pretty handy for converting ObjC callbacks
  init(value: A?, error: NSError?) {
    switch (value, error) {
    case let (.Some(v), .None):
      self = success(v)
    case let (.None, .Some(e)):
      self = failure(e)
    default:
      // This should never happen. Return it as a failure
      fatalError("Received both or neither value and error")
      self = .Failure(NSError(localizedDescription:"Received both or neither value and error"))
    }

    func isSuccess() -> Bool {
      switch self {
      case .Success(_): return true
      case .Failure(_): return false
    }
}
  }

  func map<B>(f: A -> B) -> Result<B> {
    switch self {
    case Success(let box):
      return success(f(box.unbox))
    case Failure(let err):
      return failure(err)
    }
  }

  func flatMap<B>(f:A -> Result<B>) -> Result<B> {
    switch self {
    case Success(let value):
      return f(value.unbox)
    case Failure(let error):
      return failure(error)
    }
  }
}

func flatMap<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
  switch a {
  case .Success(let boxA):
    return f(boxA.unbox)
  case .Failure(let err):
    return .Failure(err)
  }
}

func successes<A>(results: [Result<A>]) -> [A] {
  return results.reduce([A]()) { successes, result in
    switch result {
      case .Success(let value): return successes + [value.unbox]
      case .Failure(_): return successes
    }
  }
}

func failures<A>(results: [Result<A>]) -> [NSError] {
  return results.reduce([NSError]()) { failures, result in
    switch result {
      case .Success(_): return failures
      case .Failure(let error): return failures + [error]
    }
  }
}

func sequence<A>(results: [Result<A>]) -> Result<[A]> {
  return results.reduce(Result.Success(Box([A]()))) { acc, result in
    switch (acc, result) {
      case (.Success(let successes), .Success(let success)):
        return .Success(Box(successes.unbox + [success.unbox]))
      case (.Success(let successes), .Failure(let error)):
        return .Failure(error)
      default: return acc
    }
  }
}

func ??<T>(result: Result<T>, defaultValue: @autoclosure () -> T) -> T {
  switch result {
  case .Success(let value):
    return value.unbox
  case .Failure(let error):
    return defaultValue()
  }
}

final class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}

infix operator >>== {associativity left}

func >>==<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
  return a.flatMap(f)
}

infix operator <*> {associativity left}

func <*><A,B>(f: A -> B, a: Result<A>) -> Result<B> {
  return a.map(f)
}

infix operator <**> {associativity left}
func <**><A,B>(a: Result<A>, f: A -> B) -> Result<B> {
  return a.map(f)
}

infix operator <^> {associativity left}

func <^><A,B>(f: A -> B, a: A) -> Result<B> {
  return f <*> .Success(Box(a))
}

extension NSError {
  convenience init(localizedDescription: String) {
    self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
  }
  convenience init(localizedDescription: String, underlyingError: NSError) {
    self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription, NSUnderlyingErrorKey: underlyingError])
  }
}

extension Optional {
  func flatMap<U>(f: T -> U?) -> U? {
    if let t = self {
      if let u = f(t) {
        return u
      }
    }
    return nil
  }

  func isSome() -> Bool {
    switch self {
    case .Some(_): return true
    case .None: return false
    }
  }
}