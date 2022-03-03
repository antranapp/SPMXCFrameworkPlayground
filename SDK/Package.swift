// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SDK",
    products: [
        .library(
            name: "SDK",
            type: .dynamic,
            targets: ["SDK"]),
    ],
    dependencies: [
        .package(path: ".//ModuleA")
    ],
    targets: [
        .target(
            name: "SDK",
            dependencies: ["ModuleA"]
        ),
        .testTarget(
            name: "SDKTests",
            dependencies: ["SDK"]
        ),
    ]
)
