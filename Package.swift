// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Verso",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Verso", targets: ["Verso"])
    ],
    targets: [
        .target(name: "Verso"),
        .testTarget(name: "VersoTests", dependencies: ["Verso"])
    ]
)
