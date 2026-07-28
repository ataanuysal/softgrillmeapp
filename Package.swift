// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "GrillMe",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "GrillMeCore", targets: ["GrillMeCore"])
  ],
  targets: [
    .target(
      name: "GrillMeCore",
      path: "GrillMe/Core"
    ),
    .testTarget(
      name: "GrillMeCoreTests",
      dependencies: ["GrillMeCore"],
      path: "Tests/GrillMeCoreTests"
    ),
  ]
)
