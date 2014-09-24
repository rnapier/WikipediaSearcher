//
// Version 1 of pagesFromData from Functional Wish Fulfillment
// http://robnapier.net/functional-wish-fulfillment
//

import Foundation

func pagesFromData(data: NSData) -> PageListResult {

  // 1. Parse the NSData into a JSON object
  var error: NSError?
  let json: JSON? = NSJSONSerialization.JSONObjectWithData(data,
    options: NSJSONReadingOptions(0), error: &error)

  if let json: JSON = json {

    // 2. Make sure the JSON object is an array
    if let array = json as? JSONArray {

      // 3. Get the second element
      if array.count < 2 {
        // Failure leg for 3
        return .Failure(NSError(localizedDescription:
          "Could not get second element. Array too short: \(array.count)"))
      }
      let element: JSON = array[1]

      // 4. Make sure the second element is a list of strings
      if let titles = element as? [String] {

        // 5. Convert those strings into pages
        return .Success(titles.map { Page(title: $0) })
      }
      else {
        // Failure leg for 4
        return .Failure(NSError(localizedDescription: "Expected string list. Got: \(array[1])"))
      }
    }
    else {
      // Failure leg for 2
      return .Failure(NSError(localizedDescription: "Expected array. Got: \(json)"))
    }
  }
  else if let error = error {
    // Failure leg for 1
    return .Failure(error)
  }
  else {
    fatalError("Received neither JSON nor an error")
    return .Failure(NSError())
  }
}

//
// Some basic types
//
typealias JSON = AnyObject
typealias JSONArray = [JSON]

struct Page {
  let title: String
}

extension Page: Printable {
  var description: String {
    return title
  }
}

enum PageListResult {
  case Success([Page])
  case Failure(NSError)
}

extension PageListResult: Printable {
  var description: String {
    switch self {
    case .Success(let pages):
      return "Success: " + join(", ", pages.map { "\"\($0.description)\""})
    case .Failure(let error):
      return "Failure: \(error.localizedDescription)"
      }
  }
}

//
// A little helper to make errors easier
//
extension NSError {
  convenience init(localizedDescription: String) {
    self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
  }
}

//
// TESTS
//

// Helper function for tests below
func asJSONData(string: NSString) -> NSData {
  return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
}

let goodPagesJson = asJSONData("[\"a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]")

pagesFromData(goodPagesJson).description

let corruptJson = asJSONData("a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]")

pagesFromData(corruptJson).description
