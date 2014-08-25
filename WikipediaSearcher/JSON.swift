//
//  JSON.swift
//  WikiStuff
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation

// Inspired by http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics

typealias JSON = AnyObject
typealias JSONArray = [JSON]

//enum JSONResult {
//  case Success(JSON)
//  case Failure(NSError)
//}

func asJSON(data: NSData) -> Result<JSON> {
  var error: NSError?
  let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)

  switch (json, error) {
  case (_, .Some(let error)): return .Failure(error)

  case (.Some(let json), _): return .Success(Box(json))

  default:
    fatalError("Received neither JSON nor an error")
    return .Failure(NSError())
  }
}
