import Foundation
import RegexBuilder

enum JSONState {
  case key
  case value
  case object
  case string
  case nothing
  case comma
  case colon
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
        if stateStack.last == .comma {
          error.append("Invalid comma at the end of the object")
        }
        stateStack.removeLast()
        if stateStack == [.nothing] {
          stateStack = []
        }
      case ",":
        state = .comma
        stateStack.append(.comma)
      case "\"":
        if state == .comma {
          stateStack.removeLast()
          stateStack.append(.key)
          state = .key
        } else if state == .key {
          if stateStack.last == .key {
            stateStack.removeLast()
          } else {
            error.append("Keyend outside of key.")
          }
        } else if state == .colon {
          // string start
        } else if state == .string {
          // string end
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
