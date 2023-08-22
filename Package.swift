// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GeoFire",
    defaultLocalization: "en",
    platforms: [.iOS(.v11), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v7)],
    products: [
        .library(
            name: "GeoFire",
            targets: ["GeoFire"]
        ),
        .library(
            name: "GeoFireUtils",
            targets: ["GeoFireUtils"]
        )
    ],
    dependencies: [
        .package(name: "Firebase",
                 url: "https://github.com/firebase/firebase-ios-sdk.git",
                 "7.0.0"..<"11.0.0"),
    ],
    targets: [
        .target(
            name: "GeoFire",
            dependencies: [
                "GeoFireUtils",
                .product(name: "FirebaseDatabase", package: "Firebase")
            ],
            path: "GeoFire",
            exclude: [
                "./Utils",
            ],
            publicHeadersPath: "./API"
        ),
        .testTarget(
            name: "GeoFireTests",
            dependencies: [
                "GeoFire"
            ],
            path: "GeoFireTests",
            exclude: [
                "GeoFireTests-Info.plist",
            ],
            cSettings: [
                .headerSearchPath("../GeoFire/API"),
                .headerSearchPath("../GeoFire/Utils"),
            ]
        ),
        .target(
            name: "GeoFireUtils",
            path: "GeoFire/Utils",
            publicHeadersPath: "."
        )
    ]
)
