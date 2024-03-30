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

class JSONValidator {

  var error: [String] = []

  func validate(_ content: String) -> [String] {
    if content.first == "{" {
      var it = 0
      while it < content.count && content[it] != "}" {
        it = it + 1
        while content[it].isWhitespace || content[it].isWhitespace {
          it = it + 1
        }
        if content[it] == "}" {
          continue
        } else if content[it] == "\"" {
          it = it + 1
          while content[it] != "\"" {
            if !content[it].isLetter && !content[it].isNumber {
              error.append("invalid character")
            }
            it = it + 1
          }
        } else if content[it] == "," {
          if content[it + 1] == "}" {
            error.append("invalid , at object end")
          }
          it = it + 1
        } else if content[it] == ":" {
          it = it + 1
        } else {
          if content[it].isLetter {
            if content[it] == "t" && content[it..<it + 4] == "true" {
              print("true")
              it = it + 4
            } else if content[it] == "f" && content[it..<it + 5] == "false" {
              print("false")
              it = it + 5
            }
          } else if content[it].isNumber {
            print("number")
            while content[it] != "," && content[it] != "}" {
              it = it + 1
            }
          } else {
            error.append("Expected \" and key")
            while content[it] != ":" && content[it] != "," {
              it = it + 1
            }
          }
        }
      }
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

// TODO rebuild because shit
