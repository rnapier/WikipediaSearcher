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
typealias JSONDictionary = [String: JSON]

func failedWith<T>(errorPointer: NSErrorPointer, error: NSError) -> T? {
    if errorPointer != nil {
        errorPointer.memory = error
    }
    return nil
}

func asJSON(data: NSData, error: NSErrorPointer) -> JSON? {
    return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: error)
}

func asJSONArray(json: JSON, error: NSErrorPointer) -> JSONArray? {
    return json as? JSONArray
        ?? failedWith(error, NSError(localizedDescription: "Expected array. Got: \(json)"))
}

func asJSONDictionary(json: JSON, error: NSErrorPointer) -> JSONDictionary? {
    return json as? JSONDictionary
        ?? failedWith(error, NSError(localizedDescription: "Expected dictionary. Got: \(json)"))
}

func atIndex(array: JSONArray, index: Int, error: NSErrorPointer) -> JSON? {
    if array.count < index {
        return failedWith(error, NSError(localizedDescription:"Could not get element at index (\(index)). Array too short: \(array.count)"))
    }
    return array[index]
}

func forKey(dictionary: JSONDictionary, key: String, error: NSErrorPointer) -> JSON? {
    return dictionary[key]
        ?? failedWith(error, NSError(localizedDescription: "Could not find element for key (\(key))."))
}

func asString(json: JSON, error: NSErrorPointer) -> String? {
    return json as? String
        ?? failedWith(error, NSError(localizedDescription: "Expected string. Got: \(json)"))
}


func asStringList(json: JSON, error: NSErrorPointer) -> [String]? {
    return json as? [String]
        ?? failedWith(error, NSError(localizedDescription: "Expected string list. Got: \(json)"))
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
