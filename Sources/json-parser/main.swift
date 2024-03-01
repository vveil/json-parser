import Foundation

var arguments = CommandLine.arguments

print(arguments)

if let filePath = Array(arguments[1...]).filter({ !$0.hasPrefix("-") }).first {
  var content = ""
  if let fileContent = try? String(contentsOfFile: filePath) {
    content = fileContent
  }
  if content == "{}" {
    print("valid empty json")
    exit(0)
  }

  var contentLines = content.split(separator: "\n")
  if contentLines.count == 1 {
    contentLines = content.split(separator: " ")
  }
  print(contentLines)
  let contentWithoutNewlinesAndWhitespaces = content.replacingOccurrences(
    of: "\\s+", with: "", options: .regularExpression)

  if contentWithoutNewlinesAndWhitespaces.contains("{,") {
    print("invalid symbol in front of opening bracket")
  }
  if contentWithoutNewlinesAndWhitespaces.contains(",}") {
    print("invalid symbol in front of closing bracket")
  }

  print("invalid json")
  exit(1)
}
