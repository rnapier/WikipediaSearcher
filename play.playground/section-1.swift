struct Customer {
  let name: String
  let emails: [String]
}

let customers = [
  Customer(name: "Alice", emails: ["alice@example.com"]),
  Customer(name: "Bob", emails: ["bob@example.org", "bobby@home.example"])]

let names = customers.map { $0.name }
names

let emails = customers.map { $0.emails }
emails

func flatten<T>(array: [[T]]) -> [T] {
  var result = [T]()
  for subarray in array {
    result.extend(subarray)
  }
  return result
}

let flatEmails = flatten(customers.map { $0.emails })
flatEmails

extension Array {
  func flatMap<U>(transform: T -> [U]) -> [U] {
    return flatten(self.map(transform))
  }
}

let flatMapEmails = customers.flatMap { $0.emails }
