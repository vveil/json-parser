import Foundation
import RegexBuilder

enum JSONState {
  case key
  case value
  case object
  case string
  case nothing
}

class JSONValidator {
  var stateStack: [JSONState] = [.nothing]
  var state: JSONState = .nothing
  var error: [String] = []
  func validate(_ content: String) -> [String] {
    for char in content {
      switch char {
      case "{":
        stateStack.append(.object)
      case "}":
        stateStack.removeLast()
        if stateStack == [.nothing] {
          stateStack = []
        }
      default:
        break
      }
    }
    if !stateStack.isEmpty {
      error.append("Invalid JSON")
    }
    return error
  }
}

var arguments = CommandLine.arguments

print(arguments)

if let filePath = Array(arguments[1...]).filter({ !$0.hasPrefix("-") }).first {
  var content = ""
  if let fileContent = try? String(contentsOfFile: filePath) {
    content = fileContent
  }

  let error = JSONValidator().validate(content)
  if error.isEmpty {
    print("Valid JSON")
  } else {
    print(error.joined(separator: "\n"))
  }

}
