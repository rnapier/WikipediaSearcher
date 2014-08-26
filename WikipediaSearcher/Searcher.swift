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

private func searchURLForString(text: String) -> NSURL {
  return NSURL(string: "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\(text)&format=json")
}