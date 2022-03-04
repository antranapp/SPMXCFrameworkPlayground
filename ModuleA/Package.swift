// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ModuleA",
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: []),
        .testTarget(
            name: "ModuleATests",
            dependencies: ["ModuleA"]),
    ]
)
