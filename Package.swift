// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "json-parser",
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
