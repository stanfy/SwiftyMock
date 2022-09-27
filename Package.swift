// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftyMock",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "SwiftyMock", targets: ["SwiftyMock"])
    ],
    targets: [
        .target(name: "SwiftyMock", path: "SwiftyMock", exclude: ["Templates"])
    ]
)
