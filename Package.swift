// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "HeylelCore",
	platforms: [ .macOS(.v10_12), ],
	products: [
		.library(
			name: "HeylelCore",
			type: .dynamic,
			targets: ["HeylelCore", "HeylelNetwork", "HeylelCollections"]),
		.library(
			name: "HeylelCollections",
			targets: ["HeylelCollections"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "HeylelNetwork",
			dependencies: ["HeylelCore"]),
		.target(
			name: "HeylelCore",
			dependencies: ["HeylelCollections"]),
		.target(
			name: "HeylelCollections",
			dependencies: []),
		.testTarget(
			name: "HeylelCoreTests",
			dependencies: ["HeylelCore"]),
	]
)
