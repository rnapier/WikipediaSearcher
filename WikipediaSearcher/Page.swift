//
//  Page.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

struct Page {
  let title: String
}

func pagesFromOpenSearchData(data: NSData) -> Result<[Page]> {
  return asJSON(data)
    >>== asJSONArray
    >>== atIndex(1)
    >>== asStringList
    >>== asPages
}
