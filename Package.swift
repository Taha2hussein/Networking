// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyNetworkManger",
    products: [
        .library(
            name: "MyNetworkManger",
            targets: ["MyNetworkManger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.0.0"),
    ],
    targets: [
        .target(
            name: "MyNetworkManger",
            dependencies: ["ReactiveSwift"]),
    ]
)
