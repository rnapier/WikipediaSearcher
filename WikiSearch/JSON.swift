//
//  JSON.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

// Inspired by http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics

typealias JSON = AnyObject
typealias JSONArray = [JSON]
typealias JSONDictionary = [String: JSON]

enum JSONError : ErrorType {
    case BadArray(JSON)
    case BadDictionary(JSON)
    case OutOfRange
    case MissingKey
    case BadString(JSON)
    case BadStringList(JSON)
}

func asJSON(data: NSData) throws -> JSON {
    return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
}

func asJSONArray(json: JSON) throws -> JSONArray {
    if let array = json as? JSONArray {
        return array
    } else {
        throw JSONError.BadArray(json)
    }
}

func asJSONDictionary(json: JSON) throws -> JSONDictionary {
    if let dictionary = json as? JSONDictionary {
        return dictionary
    } else {
        throw JSONError.BadDictionary(json)
    }
}

func atIndex(index: Int)(_ array: JSONArray) throws -> JSON {
    if array.count < index {
        throw JSONError.OutOfRange
    }
    return array[index]
}

func forKey(key: String)(dictionary: JSONDictionary) throws -> JSON {
    if let value: JSON = dictionary[key] {
        return value
    } else {
        throw JSONError.MissingKey
    }
}

func asString(json: JSON) throws -> String {
    if let string = json as? String {
        return string
    } else {
        throw JSONError.BadString(json)
    }
}
func asStringList(json: JSON) throws -> [String] {
        if let stringList = json as? [String] {
        return stringList
    } else {
        throw JSONError.BadStringList(json)
    }
}

func asPages(titles: [String]) -> [Page] {
    return titles.map { Page(title: $0) }
}

//func asPage(dictionary: JSONDictionary) -> Result<Page> {
//  return success(dictionary)
//    >>== forKey("title") >>== asString
//    <**> { Page(title: $0) }
//}
//
//func asPages(array: JSONArray) -> Result<[Page]> {
//  return sequence(array.map {
//    success($0) >>== asJSONDictionary
//      >>== asPage
//    })
//}
//
