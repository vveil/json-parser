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

  func increaseIt(callFrom: String) {
    it = it + 1
  }

  func skipToCommaOrCurlyBrace() {
    while content[it] != "," && content[it] != "}" {
      increaseIt(callFrom: "skipToCommaOrCurlyBrace")
    }
  }

  func skipWhitespaces() {
    if it >= content.count {
      return
    }
    while content[it].isWhitespace || content[it].isNewline {
      if it >= content.count {
        break
      }
      increaseIt(callFrom: "skipWhitespaces")
    }
  }

  func getLastCharExceptWhitespaces() -> Character {
    var tmpIt = it - 1
    while content[tmpIt].isWhitespace || content[tmpIt].isNewline {
      tmpIt = tmpIt - 1
    }
    return content[tmpIt]
  }

  func parseObject() {
    print("in parseObject")
    while content[it] != "}" {
      if content[it] == "\"" {
        increaseIt(callFrom: "1 \"")
        while content[it] != "\"" {
          if !content[it].isLetter && !content[it].isNumber {
            error.append("invalid character")
          }
          increaseIt(callFrom: "2 \"")
        }
        increaseIt(callFrom: "3 \"")
      } else if content[it] == "," {
        if content[it + 1] == "}" {
          error.append("invalid , at object end")
        }
        increaseIt(callFrom: ",")
      } else if content[it] == ":" {
        increaseIt(callFrom: ":")
        skipWhitespaces()
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
          print("content[it] on key error: \(content[it])")
          while content[it] != ":" && content[it] != "," {
            increaseIt(callFrom: "Expected \" and key")
          }
        }
      }
    }
  }

  func validate() -> [String] {
    if content.first == "{" {
      while it < content.count {
        increaseIt(callFrom: "validate")
        skipWhitespaces()
        if it >= content.count {
          break
        }
        if content[it] == "}" {
          continue
        } else if content[it] == "{" {
          if getLastCharExceptWhitespaces() != ":" {
            error.append("Expected key")
            continue
          }
          increaseIt(callFrom: "{")
          parseObject()
        }
        parseObject()
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
