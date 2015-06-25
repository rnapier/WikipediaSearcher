//
//  Page.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/9/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

struct Page {
    let title: String
}

extension Page : CustomStringConvertible {
    var description: String { return self.title }
}

// Crazy, but maybe brilliant, idea by @radexp
// https://twitter.com/radexp/status/608754347061706752
infix operator ?! {}
func ?! <T>(a: T?, @autoclosure e: () -> ErrorType) throws -> T {
    if let a = a {
        return a
    } else {
        throw e()
    }
}

extension Array {
    subscript(safe index: Int) -> T? {
        guard index < self.endIndex else { return nil }
        return self[index]
    }
}

func pagesFromOpenSearchData(data: NSData) throws -> [Page] {
    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())

    return try
        (json as? [JSON])
            .flatMap { $0[safe: 1] }
            .flatMap { $0 as? [String] }
            .map { $0.map { Page(title: $0)}}
        ?! Error.BadJSON(json)
}
