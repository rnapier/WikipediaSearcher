//
//  Searcher.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

typealias Search = Operation<[Page]>

class Searcher : OperationHandler {
    func search(text: String, completionHandler: (() throws -> [Page]) -> Void) -> Search {
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
    let url = (text as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        .map { "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\($0)&format=json" }
        .flatMap { NSURL(string: $0) }

    precondition(url != nil, "Could not encode URL")
    return url!
}

func pagesFromOpenSearchData(data: NSData) throws -> [Page] {
    return try asPages(
        asStringList(
            atIndex(1)(
                asJSONArray(
                    asJSON(data)))))
}
