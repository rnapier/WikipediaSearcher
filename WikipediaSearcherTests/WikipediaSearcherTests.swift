//
//  WikiStuffTests.swift
//  WikiStuffTests
//
//  Created by Rob Napier on 8/16/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import UIKit
import XCTest

let goodPagesJson = "[\"a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]"

let corruptJson = "a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]"

let missingArray = "{\"a\":[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]}"

let shortArray = "[\"a\"]"

let notStringList = "[\"a\",[1,\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]"


class WikiStuffTests: XCTestCase {

  func testGoodPages() {
    let data = goodPagesJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    XCTAssert(data != nil, "Failed to create data")

    let pages = pagesFromData3(data!)
    switch pages {
    case .Success(let pages):
      XCTAssertEqual(pages.unbox.count, 15)
    case .Failure(let err):
      XCTFail("pages failed: \(err)")
    }
  }

  func testCorruptJSON() {
    let data = corruptJson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    XCTAssert(data != nil, "Failed to create data")

    let pages = pagesFromData3(data!)
    switch pages {
    case .Success(let boxa):
      XCTFail("Parsed when it shouldn't have: \(boxa)")
    case .Failure(let err):
      XCTAssertEqual(err.code, 3840)
    }
  }

  func testMissingArray() {
    let data = missingArray.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    XCTAssert(data != nil, "Failed to create data")

    let pages = pagesFromData3(data!)
    switch pages {
    case .Success(let boxa):
      XCTFail("Parsed when it shouldn't have: \(boxa)")
    case .Failure(let err):
      XCTAssert(err.localizedDescription.hasPrefix("Expected array."), err.localizedDescription)
    }
  }

  func testShortArray() {
    let data = shortArray.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    XCTAssert(data != nil, "Failed to create data")

    let pages = pagesFromData3(data!)
    switch pages {
    case .Success(let boxa):
      XCTFail("Parsed when it shouldn't have: \(boxa)")
    case .Failure(let err):
      XCTAssert(err.localizedDescription.hasPrefix("Could not get second element."), err.localizedDescription)
    }
  }

  func testNotStringList () {
    let data = notStringList.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    XCTAssert(data != nil, "Failed to create data")

    let pages = pagesFromData(data!)
    switch pages {
    case .Success(let boxa):
      XCTFail("Parsed when it shouldn't have: \(boxa)")
    case .Failure(let err):
      XCTAssert(err.localizedDescription.hasPrefix("Expected string list."), err.localizedDescription)
    }
  }
}
