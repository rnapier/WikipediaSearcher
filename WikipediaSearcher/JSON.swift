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
typealias JSONDictionary = Dictionary<String, JSON>
typealias JSONObject = JSONDictionary
typealias JSONArray = [JSON]

func ParseJSON(#data: NSData) -> Result<JSON> {

  var jsonError: NSError?
  let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonError)

  return Result(value: json, error: jsonError)
}
