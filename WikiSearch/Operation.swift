//
//  Operation.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

class OperationHandler {
    let queue: NSOperationQueue = NSOperationQueue.mainQueue()
}

struct Operation<ResultType> {
    let task: NSURLSessionDataTask?

    init(url: NSURL, queue: NSOperationQueue, parser: (NSData) throws -> ResultType, completionHandler: (() throws -> ResultType) -> Void) {
        let handler = operationHandler(queue: queue, parser: parser, completionHandler: completionHandler)
        self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: handler)
        self.task?.resume()
    }

    func cancel() {
        self.task?.cancel()
    }
}

private func operationHandler<T>(queue queue: NSOperationQueue, parser: (NSData) throws -> T, completionHandler: (() throws -> T) -> Void)
    (data: NSData?, _: NSURLResponse?, error: NSError?)
{
    switch (data, error) {

    case (_, .Some(let error)) where error.isCancelled():
        break // Ignore cancellation

    case (_, .Some(let error)):
        queue.addOperationWithBlock {completionHandler({ throw error })}

    case (.Some(let data), _):
        queue.addOperationWithBlock {completionHandler({ try parser(data) })}

    default:
        fatalError("Did not receive an error or data.")
    }
}