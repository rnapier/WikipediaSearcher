//
//  Searcher.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

typealias JSON = AnyObject

enum Error : ErrorType {
    case BadJSON(JSON)
    case Cancelled
    case Unknown
}

class Search {
    let text: String

    private var task: NSURLSessionDataTask?
    private let resultQueue: dispatch_queue_t

    private var data: NSData?
    private var error: NSError?

    init(text: String) {
        self.text = text
        self.resultQueue = dispatch_queue_create("search.future", DISPATCH_QUEUE_CONCURRENT)

        dispatch_suspend(self.resultQueue)

        let url = searchURLForString(text)

        self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, err) in
            self.data = data
            self.error = err
            dispatch_resume(self.resultQueue)
        })
        precondition(self.task != nil, "Could not create task")

        self.task?.resume()
    }

    func result() throws -> [Page] {
        var d : NSData?
        var e : NSError?
        dispatch_sync(self.resultQueue, {
            d = self.data
            e = self.error
        })

        if let e = e {
            if e.domain == NSURLErrorDomain && e.code == NSURLErrorCancelled {
                throw Error.Cancelled
            } else {
                throw e
            }
        }

        if let d = d {
            return try pagesFromOpenSearchData(d)
        }

        throw Error.Unknown
    }

    func cancel() {
        self.task?.cancel()
        self.task = nil
    }
}

private func searchURLForString(text: String) -> NSURL {
    let url = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        .map { "https://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\($0)&format=json" }
        .flatMap { NSURL(string: $0) }

    precondition(url != nil, "Could not encode URL")
    return url!
}

// Crazy, but maybe brilliant, idea by @radexp
// https://twitter.com/radexp/status/608754347061706752
infix operator ?! {}
func ?! <T>(a: T?, @autoclosure e: () -> ErrorType) throws -> T {
    if let a = a {
        return a
    } else {
        throw e()
    }
}

extension Array {
    subscript(safe index: Int) -> T? {
        guard index < self.endIndex else { return nil }
        return self[index]
    }
}

func pagesFromOpenSearchData(data: NSData) throws -> [Page] {
    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())

    return try
        (json as? [JSON])
            .flatMap { $0[safe: 1] }
            .flatMap { $0 as? [String] }
            .map { $0.map { Page(title: $0)}}
        ?! Error.BadJSON(json)
}
