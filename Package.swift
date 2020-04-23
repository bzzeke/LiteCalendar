// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiteCalendar",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LiteCalendar",
            targets: ["LiteCalendar"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LiteCalendar",
            dependencies: ["SnapKit"]),
        .testTarget(
            name: "LiteCalendarTests",
            dependencies: ["LiteCalendar"]),
    ]
)
