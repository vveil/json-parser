import Foundation

var arguments = CommandLine.arguments

print(arguments)

let filePath = Array(arguments[1...]).filter({ !$0.hasPrefix("-") }).first {
var content = ""
if let fileContent = try? String(contentsOfFile: path) {
  content = fileContent
}
