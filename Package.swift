// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "geofire-objc",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "GeoFire",
            targets: ["GeoFire"]),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "GeoFire",
            dependencies: [],
            path: "GeoFire/Implementation"
        ),
        .testTarget(
            name: "GeoFireTests",
            dependencies: ["GeoFire"]),
    ]
)
