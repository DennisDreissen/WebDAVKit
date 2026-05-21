// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WebDAVKit",
    platforms: [
        .iOS(.v15), .macOS(.v12), .tvOS(.v15), .visionOS(.v1)
    ],
    products: [
        .library(
            name: "WebDAVKit",
            targets: ["WebDAVKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.18.1")
    ],
    targets: [
        .target(
            name: "WebDAVKit",
            dependencies: [
                .product(name: "XMLCoder", package: "XMLCoder")
            ]
        ),
        .testTarget(
            name: "WebDAVKitTests",
            dependencies: ["WebDAVKit"]
        ),
        .testTarget(
            name: "WebDAVKitIntegrationTests",
            dependencies: ["WebDAVKit"]
        )
    ],
    swiftLanguageModes: [.v6]
)
