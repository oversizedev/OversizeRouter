// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription
import Foundation

let remoteDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
]

let localDependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeModels", path: "../OversizeModels"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
]

var dependencies: [PackageDescription.Package.Dependency] = localDependencies

if ProcessInfo.processInfo.environment["BUILD_MODE"] == "PRODUCTION" {
    dependencies = remoteDependencies
}

let package = Package(
    name: "OversizeRouter",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "OversizeRouter",
            targets: ["OversizeRouter"]
        ),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "OversizeRouter",
            dependencies: [
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "OversizeModels", package: "OversizeModels"),
                .product(name: "OversizeLocalizable", package: "OversizeLocalizable"),
            ]
        ),
        .testTarget(
            name: "OversizeRouterTests",
            dependencies: ["OversizeRouter"]
        ),
    ]
)
