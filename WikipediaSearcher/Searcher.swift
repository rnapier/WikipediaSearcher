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
  return NSURL(string: "http://en.wikipedia.org/w/api.php?action=opensearch&limit=15&search=\(text)&format=json")!
}

func pagesFromOpenSearchData(data: NSData) -> Result<[Page]> {
  return asJSON(data)
    >>== asJSONArray
    >>== atIndex(1)
    >>== asStringList
    >>== asPages
}
