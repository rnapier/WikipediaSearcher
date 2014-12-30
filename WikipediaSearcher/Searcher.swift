//
//  Searcher.swift
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

typealias Search = Operation<[Page]>

class Searcher : OperationHandler {
    func search(text: String, completionHandler: (Result<[Page]>) -> Void) -> Search {
        let url = searchURLForString(text)
        return Operation(url: url, queue: queue, parser: pagesFromOpenSearchData, completionHandler: completionHandler)
    }
}

extension NSError {
    func isCancelled() -> Bool {
        return self.domain == NSURLErrorDomain && self.code == NSURLErrorCancelled
    }
}

private func searchURLForString(text: String) -> NSURL {
    let url = (text as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        .map { "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\($0)&format=json" }
        .flatMap { NSURL(string: $0) }

    precondition(url.isSome(), "Could not encode URL")
    return url!
}

func pagesFromOpenSearchData(data: NSData) -> Result<[Page]> {
    var error: NSError?

    let pages = asJSON(data, &error)
        .flatMap { asJSONArray($0, &error) }
        .flatMap { atIndex($0, 1, &error) }.flatMap{ asStringList($0, &error) }
        .flatMap { asPages($0) }

    println("\(pages)  \(error)")

    return Result(value: pages, error: error)
}
