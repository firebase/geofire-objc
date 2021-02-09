// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "geofire-objc",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GeoFire",
            targets: ["GeoFire"]
        )
    ],
    dependencies: [
        .package(
            name: "Firebase", 
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            "7.0.0" ..< "7.6.0"
        ),
        .package(
            name: "FirebaseFirestore", 
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .exact("1.19.0")
        )
    ],
    targets: [
        .target(
            name: "GeoFire",
            dependencies: [
                "Firebase",
                "FirebaseFirestore"
            ],
            path: "GeoFire/Implementation"
        ),
        .testTarget(
            name: "GeoFireTests",
            dependencies: ["GeoFire"]
        )
    ]
)
