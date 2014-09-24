import Foundation

func pagesFromData(data: NSData) -> Result<[Page]> {
  return continueWith(asJSON(data)) {
    continueWith(asJSONArray($0)) {
      continueWith(secondElement($0)) {
        continueWith(asStringList($0)) {
          asPages($0)
        }}}}}

func continueWith<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
  switch a {
  case .Success(let boxA):
    return f(boxA.unbox)
  case .Failure(let err):
    return .Failure(err)
  }
}

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

func asJSONArray(json: JSON) -> Result<JSONArray> {
  if let array = json as? JSONArray {
    return .Success(Box(array))
  } else {
    return .Failure(NSError(localizedDescription: "Expected array. Got: \(json)"))
  }
}

func secondElement(array: JSONArray) -> Result<JSON> {
  if array.count < 2 {
    return .Failure(NSError(localizedDescription:"Could not get second element. Array too short: \(array.count)"))
  }
  return .Success(Box(array[1]))
}

func asStringList(array: JSON) -> Result<[String]> {
  if let string = array as? [String] {
    return .Success(Box(string))
  } else {
    return .Failure(NSError(localizedDescription: "Unexpected string list: \(array)"))
  }
}

func asPages(titles: [String]) -> Result<[Page]> {
  return .Success(Box(titles.map { Page(title: $0) }))
}

enum Result<A> {
  case Success(Box<A>)
  case Failure(NSError)
}
final class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}

extension Result: Printable {
  var description: String {
    switch self {
    case .Success(let box):
      return "Success: \(box.unbox)"
    case .Failure(let error):
      return "Failure: \(error.localizedDescription)"
      }
  }
}

struct Page {
  let title: String
}

extension Page: Printable {
  var description: String {
    return title
  }
}

typealias JSON = AnyObject
typealias JSONArray = [JSON]

extension NSError {
  convenience init(localizedDescription: String) {
    self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
  }
}

func asJSONData(string: NSString) -> NSData {
  return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
}

let goodPagesJson = asJSONData("[\"a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]")

pagesFromData(goodPagesJson).description

let corruptJson = asJSONData("a\",[\"Animal\",\"Association football\",\"Arthropod\",\"Australia\",\"AllMusic\",\"African American (U.S. Census)\",\"Album\",\"Angiosperms\",\"Actor\",\"American football\",\"Austria\",\"Argentina\",\"American Civil War\",\"Administrative divisions of Iran\",\"Alternative rock\"]]")

pagesFromData(corruptJson).description
