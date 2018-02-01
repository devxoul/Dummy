// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Dummy",
  products: [.library(name: "Dummy", targets: ["Dummy"])],
  targets: [
    .target(name: "Dummy", dependencies: []),
    .target(name: "DummyApp", dependencies: ["Dummy"]),
    .testTarget(name: "DummyTests", dependencies: ["Dummy"]),
  ]
)
