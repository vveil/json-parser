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
      print("current char: \(char)")
      switch char {
      case "{":
        stateStack.append(.object)
        state = .object
      case "}":
        if stateStack.last == .comma {
          error.append("Invalid comma at the end of the object")
        }
        if stateStack.last == .object {
          stateStack.removeLast()
        }
        if stateStack == [.nothing] {
          stateStack = []
        }
      case ",":
        state = .comma
        stateStack.append(.comma)
      case ":":
        if state == .string {
          break
        }
        print(": case, curent stateStack: \(stateStack)")
        if stateStack.last == .key {
          stateStack.removeLast()
          state = .colon
        } else {
          error.append("invalid colon")
        }
      case "\"":
        if state == .comma || state == .object {
          stateStack.removeLast()
          stateStack.append(.key)
          state = .key
        } else if state == .key {
          if stateStack.last != .key {
            error.append("Keyend outside of key.")
            print("keyend error")
          }
        } else if state == .colon {
          // if state == .colon && stateStack.last != .key {
          //   error.append("no key given for string start")
          // }
          // string start
        } else if state == .string {
          // string end
        }

      default:
        break
      }
    }
    if !stateStack.isEmpty {
      print(stateStack)
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
