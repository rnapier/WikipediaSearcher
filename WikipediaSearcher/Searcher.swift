//
//  Searcher.swift
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

enum PageListResult {
  case Success([Page])
  case Failure(NSError)
}

func ??(result: PageListResult, defaultValue: @autoclosure () -> [Page]) -> [Page] {
  switch result {
  case .Success(let value):
    return value
  case .Failure(let error):
    return defaultValue()
  }
}

struct Searcher {
  let queue: NSOperationQueue = NSOperationQueue.mainQueue()

  func search(text: String, completionHandler: (Result<[Page]>) -> Void) -> Search {
    return Search(text: text, queue: self.queue, completionHandler: completionHandler)
  }
}

struct Search {
  let task: NSURLSessionDataTask

  init(text: String, queue: NSOperationQueue, completionHandler: Result<[Page]> -> Void) {
    let url = searchURLForString(text)

    self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: pageHandler(queue: queue, completionHandler: completionHandler))
    self.task.resume()
  }

  func cancel() {
    self.task.cancel()
  }
}

private func pageHandler(#queue: NSOperationQueue, #completionHandler: Result<[Page]> -> Void)
  (data: NSData?, _: NSURLResponse?, error: NSError?) {

    switch (data, error) {

    case (_, .Some(let error)) where error.isCancelled():
      break // Ignore cancellation

    case (_, .Some(let error)):
      queue.addOperationWithBlock({completionHandler(.Failure(error))})

    case (.Some(let data), _):
      queue.addOperationWithBlock({completionHandler(pagesFromOpenSearchData(data))})

    default:
      fatalError("Did not receive an error or data.")
    }
}

extension NSError {
  func isCancelled() -> Bool {
    return self.domain == NSURLErrorDomain && self.code == NSURLErrorCancelled
  }
}


///
/// VERSION 1
///

//func pagesFromOpenSearchData(data: NSData) -> PageListResult {
//
//  // 1. Parse the NSData into a JSON object
//  var error: NSError?
//  let json: JSON? = NSJSONSerialization.JSONObjectWithData(data,
//    options: NSJSONReadingOptions(0), error: &error)
//
//  if let json: JSON = json {
//
//    // 2. Make sure the JSON object is an array
//    if let array = json as? JSONArray {
//
//      // 3. Get the second element
//      if array.count < 2 {
//        // Failure leg for 3
//        return .Failure(NSError(localizedDescription:
//          "Could not get second element. Array too short: \(array.count)"))
//      }
//      let element: JSON = array[1]
//
//      // 4. Make sure the second element is a list of strings
//      if let titles = element as? [String] {
//
//        // 5. Convert those strings into pages
//        return .Success(titles.map { Page(title: $0) })
//      }
//      else {
//        // Failure leg for 4
//        return .Failure(NSError(localizedDescription: "Expected string list. Got: \(array[1])"))
//      }
//    }
//    else {
//      // Failure leg for 2
//      return .Failure(NSError(localizedDescription: "Expected array. Got: \(json)"))
//    }
//  }
//  else if let error = error {
//    // Failure leg for 1
//    return .Failure(error)
//  }
//  else {
//    fatalError("Received neither JSON nor an error")
//    return .Failure(NSError())
//  }
//}
//
//func pagesFromOpenSearchData2(data: NSData) -> Result<[Page]> {
//
//  // 1. Parse the NSData into a JSON object
//  switch asJSON(data) {
//  case .Success(let boxJson):
//
//    // 2. Make sure the JSON object is an array
//    switch asJSONArray(boxJson.unbox) {
//    case .Success(let boxArray):
//
//      // 3. Get the second element
//      switch secondElement(boxArray.unbox) {
//      case .Success(let elementBox):
//
//        // 4. Make sure the second element is a list of strings
//        switch asStringList(elementBox.unbox) {
//        case .Success(let titlesBox):
//
//          // 5. Convert those strings into pages
//          return asPages(titlesBox.unbox)
//
//        case .Failure(let error):
//          return .Failure(error)
//        }
//      case .Failure(let error):
//        return .Failure(error)
//      }
//    case .Failure(let error):
//      return .Failure(error)
//    }
//  case .Failure(let error):
//    return .Failure(error)
//  }
//}


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

//
//func AsPages(titles: [String]) -> PageListResult {
//  return success(titles.map { Page(title: $0) })
//}


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

infix operator »= {associativity left precedence 150}

//infix operator >== {associativity left precedence 150}

//func >==<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
//  return a.flatMap(f)
//  //  switch a {
//  //  case .Success(let boxA):
//  //    return f(boxA.unbox)
//  //  case .Failure(let err):
//  //    return .Failure(err)
//  //  }
//}
//
//func >==<A,B>(a: A, f: A -> Result<B>) -> Result<B> {
//  return success(a) >== f
//}
//
//private func pagesFromJSON(json: JSON) -> PageListResult {
//  return json
//    >== AsJSONArray
//    >== AssertLength(2)
//    >== GetIndex(1)
//    >== AsStringList
//    >== AsPages
//}

private func searchURLForString(text: String) -> NSURL {
  return NSURL(string: "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\(text)&format=json")
}