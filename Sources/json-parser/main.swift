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

  var content = ""
  var error: [String] = []
  var it = 0

  init(content: String) {
    self.content = content
  }

  func increaseIt() {
    it = it + 1
  }

  func skipToCommaOrCurlyBrace() {
    while content[it] != "," && content[it] != "}" {
      increaseIt()
    }
  }

  func skipWhitespaces() {
    while content[it].isWhitespace || content[it].isNewline {
      increaseIt()
    }
  }

  func getLastCharExceptWhitespaces() -> Character {
    var tmpIt = it - 1
    while content[tmpIt].isWhitespace || content[tmpIt].isNewline {
      tmpIt = tmpIt - 1
    }
    return content[tmpIt]
  }

  func validate() -> [String] {
    if content.first == "{" {
      while it < content.count && content[it] != "}" {
        increaseIt()
        skipWhitespaces()
        if content[it] == "}" {
          continue
        } else if content[it] == "\"" {
          increaseIt()
          while content[it] != "\"" {
            if !content[it].isLetter && !content[it].isNumber {
              error.append("invalid character")
            }
            increaseIt()
          }
        } else if content[it] == "," {
          if content[it + 1] == "}" {
            error.append("invalid , at object end")
          }
          increaseIt()
        } else if content[it] == ":" {
          increaseIt()
        } else {
          if content[it].isLetter && getLastCharExceptWhitespaces() == ":" {
            if !((content[it] == "t" && content[it..<it + 5] == "true,")
              || (content[it] == "n" && content[it..<it + 5] == "null,")
              || (content[it] == "f" && content[it..<it + 6] == "false,"))
            {
              error.append("Expected value")
            }
            skipToCommaOrCurlyBrace()
          } else if content[it].isNumber {
            skipToCommaOrCurlyBrace()
          } else {
            error.append("Expected \" and key")
            while content[it] != ":" && content[it] != "," {
              increaseIt()
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

  let error = JSONValidator(content: content).validate()
  if error.isEmpty {
    print("Valid JSON")
  } else {
    print("Invalid JSON, occured errors:")
    print(error.joined(separator: "\n"))
  }

}

// TODO rebuild because shit
