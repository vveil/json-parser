// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "json-parser",
  platforms: [.macOS(.v13)],
  products: [
    .executable(name: "json-parser", targets: ["json-parser"])
  ],
  dependencies: [
    // Add your dependencies here, if any.
  ],
  targets: [
    .target(
      name: "json-parser",
      dependencies: [])
  ]
)
