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

extension NSError {
  convenience init(localizedDescription: String) {
    self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
  }
}