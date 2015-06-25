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
    case BadResponse(NSURLResponse?)
    case HTTPFailure(NSHTTPURLResponse)
    case BadJSON(JSON)
    case NoData
    case Cancelled
    case Unknown
}

class Search {
    let text: String

    private var task: NSURLSessionDataTask?
    private let resultGroup: dispatch_group_t

    private var data: NSData?

    convenience init() { self.init(text: "") }

    init(text: String) {
        self.text = text
        self.resultGroup = dispatch_group_create()
        guard text != "" else { return }

        dispatch_group_enter(self.resultGroup)

        let url = searchURLForString(text)

        // This is a retain loop, but the task will release this closure after it fires.
        self.task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, _) in
            self.data = data
            dispatch_group_leave(self.resultGroup)
        })
        precondition(self.task != nil, "Could not create task")

        self.task?.resume()
    }

    func wait() throws -> [Page] {
        dispatch_group_wait(self.resultGroup, DISPATCH_TIME_FOREVER) // Could put a timeout here in general, but NSURLSession already gives us that

        if let err = self.task?.error {
            if err.domain == NSURLErrorDomain && err.code == NSURLErrorCancelled {
                throw Error.Cancelled
            } else {
                throw err
            }
        }

        guard let resp = self.task?.response as? NSHTTPURLResponse else {
            throw Error.BadResponse(self.task?.response)
        }

        guard 200..<300 ~= resp.statusCode else {
            throw Error.HTTPFailure(resp)
        }

        guard let d = self.data else {
            throw Error.NoData
        }

        return try pagesFromOpenSearchData(d)
    }

    func cancel() {
        self.task?.cancel()
    }
}

private func searchURLForString(text: String) -> NSURL {
    let url = text.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        .map { "https://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\($0)&format=json" }
        .flatMap { NSURL(string: $0) }

    precondition(url != nil, "Could not encode URL")
    return url!
}

