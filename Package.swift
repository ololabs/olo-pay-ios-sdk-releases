// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OloPaySDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "OloPaySDK",
            targets: ["OloPaySDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stripe/stripe-ios.git", exact: "24.5.0")
    ],
    targets: [
        .target(
            name: "OloPaySDK",
            dependencies: [
                .product(name: "Stripe", package: "stripe-ios"),
            ],
            path: "src/OloPaySDK/OloPaySDK"
        ),
        .testTarget(
            name: "OloPaySDKTests",
            dependencies: ["OloPaySDK"],
            path: "src/OloPaySDK/OloPaySDKTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
