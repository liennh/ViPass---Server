// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "api-1pass",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.5"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", from: "3.0.2"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "3.0.2"),
        .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.0"),//0.8.16
        .package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", from: "3.0.6"),
        .package(url: "https://github.com/iamjono/SwiftString.git", from: "2.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .exact("0.10.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "api-1pass",
            dependencies: ["PerfectHTTPServer",
                           "PerfectRequestLogger",
                           "BigInt",
                           "Cryptor",
                           "PerfectCURL",
                           "SwiftString",
                           "PerfectCrypto",
                           "CryptoSwift",
                           ]),
    ]
)

