//
//  WikipediaSearcher.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

struct WikipediaSearcher {
  let queue: NSOperationQueue = NSOperationQueue.mainQueue()

  func search(text: String, completionHandler: (Result<[WikipediaPage]>) -> Void) -> WikipediaSearch {
    return WikipediaSearch(text: text, queue: self.queue, completionHandler: completionHandler)
  }
}

struct WikipediaSearch {
  let task: NSURLSessionDataTask

  init(text: String, queue: NSOperationQueue, completionHandler: Result<[WikipediaPage]> -> Void) {
    let url = searchURLForString(text)

    self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: pageHandler(queue: queue, completionHandler: completionHandler))
    self.task.resume()
  }

  func cancel() {
    self.task.cancel()
  }
}

private func pageHandler(#queue: NSOperationQueue, #completionHandler: Result<[WikipediaPage]> -> Void)
  (data: NSData?, _: NSURLResponse?, error: NSError?) {

    switch (data, error) {

    case (_, .Some(let error)) where error.isCancelled():
      break // Ignore cancellation

    case (_, .Some(let error)):
      queue.addOperationWithBlock({completionHandler(failure(error))})

    case (.Some(let data), _):
      queue.addOperationWithBlock({completionHandler(pagesFromData(data))})

    default:
      fatalError("Did not receive an error or data.")
    }
}

extension NSError {
  func isCancelled() -> Bool {
    return self.domain == NSURLErrorDomain && self.code == NSURLErrorCancelled
  }
}

func pagesFromData(data: NSData) -> Result<[WikipediaPage]> {
//  let json = ParseJSON(data: data)
  //  println(NSString(data: data, encoding: NSUTF8StringEncoding))
//  return json.flatMap(pagesFromJSON)
  return data
    >== ParseJSON
    >== AsJSONArray
    >== AssertLength(2)
    >== GetIndex(1)
    >== AsStringList
    >== AsPages
}

///
/// VERSION 1
///

//private func pagesFromJSON(json: JSON) -> Result<[WikipediaPage]> {
//  if let array = json as? JSONArray {
//    if array.count != 2 {
//      return failure(NSError(localizedDescription: "Unexpected array length: \(array.count)"))
//    }
//    if let pageTitles = array[1] as? [String] {
//      return success(pageTitles.map { WikipediaPage(title: $0) })
//    }
//    else {
//      return failure(NSError(localizedDescription: "Unexpected title list: \(array[1])"))
//    }
//  }
//  else {
//    return failure(NSError(localizedDescription: "Badly-formed response. Top level was not an array."))
//  }
//}

///
/// VERSION 2
///

func AsJSONArray(json: JSON) -> Result<JSONArray> {
  if let array = json as? JSONArray {
    return success(array)
  } else {
    return failure(NSError(localizedDescription: "Expected array, received: \(json)"))
  }
}

func AssertLength<T:CollectionType>(length: T.Index.Distance)(array: T) -> Result<T> {
  let actualLength = countElements(array)
  if actualLength == length {
    return success(array)
  } else {
    return failure(NSError(localizedDescription: "Unexpected array length: \(actualLength)"))
  }
}

func GetIndex<T:CollectionType>(index: T.Index)(array: T) -> Result<T.Generator.Element> {
  return success(array[index])
}

func AsStringList(array: JSON) -> Result<[String]> {
  if let string = array as? [String] {
    return success(string)
  } else {
    return failure(NSError(localizedDescription: "Unexpected string list: \(array)"))
  }
}

func AsPages(titles: [String]) -> Result<[WikipediaPage]> {
  return success(titles.map { WikipediaPage(title: $0) })
}


//private func pagesFromJSON(json: JSON) -> Result<[WikipediaPage]> {
//  return AsJSONArray(json).flatMap { array in
//    AssertLength(2)(array: array).flatMap { array in
//      GetIndex(1)(array: array).flatMap { first in
//        AsStringList(first).flatMap { pageTitles in
//          AsPages(pageTitles)
//        }
//      }
//    }
//  }
//}

///
/// VERSION 3
///
//private func pagesFromJSON(json: JSON) -> Result<[WikipediaPage]> {
//  return AsJSONArray(json)
//    .flatMap(AssertLength(2))
//    .flatMap(GetIndex(1))
//    .flatMap(AsStringList)
//    .flatMap(AsPages)
//  }
//}

///
/// VERSION 4
///

infix operator >== {associativity left precedence 150}

func >==<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
  return a.flatMap(f)
//  switch a {
//  case .Success(let boxA):
//    return f(boxA.unbox)
//  case .Failure(let err):
//    return .Failure(err)
//  }
}

func >==<A,B>(a: A, f: A -> Result<B>) -> Result<B> {
  return success(a) >== f
}

private func pagesFromJSON(json: JSON) -> Result<[WikipediaPage]> {
  return json
    >== AsJSONArray
    >== AssertLength(2)
    >== GetIndex(1)
    >== AsStringList
    >== AsPages
}

private func searchURLForString(text: String) -> NSURL {
  return NSURL(string: "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\(text)&format=json")
}