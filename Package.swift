// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "geofire_objc",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "geofire_objc", targets: ["geofire_objc"])
    ],
    targets: [
        .target(
            name: "GeoFire",
            path: "GeoFire",
    ]
)
