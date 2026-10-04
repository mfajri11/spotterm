// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SpotTerm",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SpotTerm", targets: ["SpotTerm"])
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.20.0")
    ],
    targets: [
        .executableTarget(
            name: "SpotTerm",
            dependencies: [
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ],
            path: "Sources/SpotTerm",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SpotTermTests",
            dependencies: ["SpotTerm"],
            path: "Tests/SpotTermTests"
        )
    ]
)
