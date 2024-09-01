// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let productionDependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/oversizedev/OversizeUI.git", .upToNextMajor(from: "3.0.2")),
    .package(url: "https://github.com/oversizedev/OversizeServices.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/oversizedev/OversizeModels.git", .upToNextMajor(from: "0.1.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
    .package(url: "https://github.com/oversizedev/OversizeLocalizable.git", .upToNextMajor(from: "1.5.0")),
]

let developmentDependencies: [PackageDescription.Package.Dependency] = [
    .package(name: "OversizeUI", path: "../OversizeUI"),
    .package(name: "OversizeServices", path: "../OversizeServices"),
    .package(name: "OversizeModels", path: "../OversizeModels"),
    .package(name: "OversizeLocalizable", path: "../OversizeLocalizable"),
    .package(url: "https://github.com/hmlongco/Factory.git", .upToNextMajor(from: "2.1.3")),
]

let dependencies: [PackageDescription.Package.Dependency] = developmentDependencies

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
                .product(name: "OversizeServices", package: "OversizeServices"),
                .product(name: "OversizeStoreService", package: "OversizeServices"),
                .product(name: "OversizeUI", package: "OversizeUI"),
                .product(name: "Factory", package: "Factory"),
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
