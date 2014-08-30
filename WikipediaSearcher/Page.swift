//
//  Page.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import UIKit

struct Page {
  let title: String
}

extension Page : Printable {
  var description: String { return self.title }
}

func imagesForPage(page: Page) -> [UIImage] {
    let url = "https://en.wikipedia.org/w/api.php?action=query&titles=\(page.title)&prop=images&format=json"
    var error: NSError?
    let data = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: url)), returningResponse: nil, error: &error)

    switch (data, error) {

    case (_, .Some(let error)):
      return .Failure(error)

    case (.Some(let data), _):
      return imagesForData(data)

    default:
      fatalError("Did not receive an error or data.")
    }
  }
  return []
}