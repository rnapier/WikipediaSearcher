//
//  RandomPageGenerator.swift
//  WikipediaSearcher
//
//  Created by Rob Napier on 8/25/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

typealias RandomPagesRequest = Operation<[Page]>

class RandomPageGenerator: OperationHandler {
  func requestPages(count: Int, completionHandler: (Result<[Page]>) -> Void) -> RandomPagesRequest {
    let url = NSURL(string:"http://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnlimit=\(count)")!
    return Operation(url: url, queue: queue, parser: pagesFromRandomQueryData, completionHandler: completionHandler)
  }
}

private func pagesFromRandomQueryData(data: NSData) -> Result<[Page]> {
  return failure(NSError(localizedDescription: "Not implemented"))
//    asJSON(data)     >>== asJSONDictionary
//    >>== forKey("query")  >>== asJSONDictionary
//    >>== forKey("random") >>== asJSONArray
//    >>== asPages
}