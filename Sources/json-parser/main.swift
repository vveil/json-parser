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
  print("invalid json")
  exit(1)
}
