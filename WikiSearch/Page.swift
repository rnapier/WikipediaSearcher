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
