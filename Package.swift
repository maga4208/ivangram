// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ivangram",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ivangram", targets: ["ivangram"])
    ],
    dependencies: [
        .package(url: "https://github.com/Swiftgram/TDLibKit", branch: "main")
    ],
    targets: [
        .target(
            name: "ivangram",
            dependencies: ["TDLibKit"],
            path: "TelegramApp"
        )
    ]
)
