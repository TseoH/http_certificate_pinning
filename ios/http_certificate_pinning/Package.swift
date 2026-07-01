// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "http_certificate_pinning",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        // Plugin name contains "_", so the library name uses "-" instead.
        .library(name: "http-certificate-pinning", targets: ["http_certificate_pinning"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "http_certificate_pinning",
            dependencies: [
                "Alamofire",
                "CryptoSwift",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)