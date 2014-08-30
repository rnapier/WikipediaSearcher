//
//  Operation.swift
//  WikipediaSearcher
//
//  Created by Rob Napier on 8/26/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

class OperationHandler {
  let queue: NSOperationQueue = NSOperationQueue.mainQueue()
}

struct Operation<ResultType> {
  let task: NSURLSessionDataTask

  init(url: NSURL, queue: NSOperationQueue, parser: NSData -> Result<ResultType>, completionHandler: Result<ResultType> -> Void) {
    self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: operationHandler(queue: queue, parser: parser, completionHandler: completionHandler))
    self.task.resume()
  }

  func cancel() {
    self.task.cancel()
  }
}

private func operationHandler<T>(#queue: NSOperationQueue, #parser: NSData -> Result<T>, #completionHandler: Result<T> -> Void)
  (data: NSData?, _: NSURLResponse?, error: NSError?) {

    switch (data, error) {

    case (_, .Some(let error)) where error.isCancelled():
      break // Ignore cancellation

    case (_, .Some(let error)):
      queue.addOperationWithBlock({completionHandler(.Failure(error))})

    case (.Some(let data), _):
      queue.addOperationWithBlock({completionHandler(parser(data))})

    default:
      fatalError("Did not receive an error or data.")
    }
}