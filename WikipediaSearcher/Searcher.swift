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
    if let escaped = (text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        .map { "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\($0)&format=json" }) {
            if let url = NSURL(string: escaped) {
                return url
            }
    }
    preconditionFailure("Could not encode URL")
}

func pagesFromOpenSearchData(data: NSData) -> Result<[Page]> {
    var error: NSError?

    if let json: JSON = asJSON(data, &error) {
        if let array = asJSONArray(json, &error) {
            if let second: JSON = atIndex(array, 1, &error) {
                if let stringList = asStringList(second, &error) {
                    return success(asPages(stringList))
                }}}}

    return failure(error!)
}
