//
//  Async.swift
//  WikiSearch
//
//  Created by Rob Napier on 6/24/15.
//  Copyright © 2015 Rob Napier. All rights reserved.
//

import Foundation

func async(f: () -> Void) {
    dispatch_async(dispatch_get_global_queue(Int(0), UInt(0))) {
        f()
    }
}

func syncMain(f: () -> Void) {
    dispatch_sync(dispatch_get_main_queue()) {
        f()
    }
}

