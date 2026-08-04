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
      path: "GrillMe/Core",
      // Kavram dersleri Markdown olarak kalır ve pakete olduğu gibi kopyalanır;
      // ağaç yapısı modül/ders eşlemesinin kaynağıdır.
      resources: [.copy("Learning")]
    ),
    .testTarget(
      name: "GrillMeCoreTests",
      dependencies: ["GrillMeCore"],
      path: "Tests/GrillMeCoreTests"
    ),
  ]
)
