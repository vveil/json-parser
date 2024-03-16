import Foundation
import RegexBuilder

extension String {
  subscript(index: Int) -> Character {
    let charIndex = self.index(self.startIndex, offsetBy: index)
    return self[charIndex]
  }

  subscript(range: Range<Int>) -> Substring {
    let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
    let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
    return self[startIndex..<stopIndex]
  }

}

enum JSONState {
  case key
  case value
  case object
  case string
  case nothing
  case comma
  case colon
  case invalid
  case boolTrue
  case boolFalse
}

let trueLetters = ["t", "r", "u", "e"]
let falseLetters = ["f", "a", "l", "s", "e"]

class JSONValidator {
  var stateStack: [JSONState] = [.nothing]
  var state: JSONState = .nothing
  var error: [String] = []
  func validate(_ content: String) -> [String] {
    for (i, char) in content.enumerated() {
      switch char {
      case _ where char.isLetter:
        if stateStack.last == .comma {
          error.append("Missing \" for key")
          stateStack.removeLast()
          state = .invalid
          break
        } else if (trueLetters.contains(String(char)) && stateStack.last == .boolTrue)
          || (falseLetters.contains(String(char)) && stateStack.last == .boolFalse)
        {
          break
        }
        if stateStack.last != .string {
          if char == "t" {
            print(content[i..<i + 4])
            if content[i..<i + 5] == "true," {
              stateStack.append(.boolTrue)
              print("valid true")
            }
          } else if char == "f" {
            if content[i..<i + 6] == "false," {
              stateStack.append(.boolFalse)
              print("valid false")
            }
          } else if stateStack.last == .colon {
            error.append("Missing \" for (string)value")
            stateStack.append(.invalid)
          }
        }

      case "{":
        stateStack.append(.object)
        state = .object
      case "}":
        if stateStack.last == .comma {
          error.append("Invalid comma at the end of the object")
          stateStack.removeLast()
        }
        if stateStack.last == .object {
          stateStack.removeLast()
        }
        if stateStack == [.nothing] {
          stateStack = []
        }
      case ",":
        if state == .string {
          break
        } else if stateStack.last == .boolTrue || stateStack.last == .boolFalse
          || stateStack.last == .invalid
        {
          stateStack.removeLast()
        }
        state = .comma
        stateStack.append(.comma)
      case ":":
        if state == .string {
          break
        }
        if stateStack.last == .key {
          stateStack.removeLast()
          state = .colon
          stateStack.append(.colon)
        } else if state != .invalid {
          error.append("Invalid colon")
        }
      case "\"":
        if state == .comma || state == .object {
          stateStack.removeLast()
          stateStack.append(.key)
          state = .key
        } else if state == .key {
          if stateStack.last != .key {
            error.append("Keyend outside of key.")
          }
        } else if stateStack.last == .colon {
          stateStack.removeLast()
          stateStack.append(.string)
          // if state == .colon && stateStack.last != .key {
          //   error.append("no key given for string start")
          // }
          // string start
        } else if stateStack.last == .string {
          stateStack.removeLast()
        }

      default:
        break
      }
    }
    if !stateStack.isEmpty {
      print("stateStack at the end: \(stateStack)")
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
