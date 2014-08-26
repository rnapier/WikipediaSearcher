//
//  RandomPageGenerator.swift
//  WikipediaSearcher
//
//  Created by Rob Napier on 8/25/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

class RandomPageGenerator {
  func nextPages(count: Int) -> Result<[Page]> {
    let randomURL = "http://en.wikipedia.org/w/api.php?action=query&format=json&list=random&rnlimit=\(count)"
    var error: NSError?
    let data = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: randomURL)), returningResponse: nil, error: &error)

    switch (data, error) {

    case (_, .Some(let error)):
      return .Failure(error)

    case (.Some(let data), _):
      return pagesFromRandomQueryData(data)

    default:
      fatalError("Did not receive an error or data.")
    }
  }
}

func pagesFromRandomQueryData(data: NSData) -> Result<[Page]> {
  return asJSON(data)     >>== asJSONDictionary
    >>== forKey("query")  >>== asJSONDictionary
    >>== forKey("random") >>== asJSONArray
    >>== asPages
}