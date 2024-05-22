//
//  main.swift
//  spatialPhotoCombiner
//
//  Created by Scott Jann on 4/1/24.
//

import Foundation
import AVFoundation
import UniformTypeIdentifiers
import ArgumentParser


struct SpatialPhotoCombiner: ParsableCommand {
	@Option(name: [ .short, .customLong("left") ], help: "The path to the left image.")
	var leftImagePath: String

	@Option(name: [ .short, .customLong("right") ], help: "The path to the right image.")
	var rightImagePath: String

	@Option(name: [ .short, .customLong("output") ], help: "The output path for the combined HEIC image.")
	var outputImagePath: String

	@Option(name: .customLong("hfov"), help: "Horizontal field-of-view (in degrees).")
	var hFOV = 55.0

	static let configuration = CommandConfiguration(commandName: "spatialPhotoCombiner")

	func run() throws {
		guard let leftImg = loadImage(at: leftImagePath) else {
			throw ValidationError("The left image could not be loaded.")
		}

		guard let rightImg = loadImage(at: rightImagePath) else {
			throw ValidationError("The right image could not be loaded.")
		}

		combineImages(leftImg: leftImg, rightImg: rightImg, outputPath: outputImagePath)
	}

	func loadImage(at path: String) -> CGImage? {
		if let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
		   let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
			return cgImage
		} else {
			return nil
		}
	}

	func combineImages(leftImg: CGImage, rightImg: CGImage, outputPath: String) {
		let newImageURL = URL(fileURLWithPath: outputPath)
		let destination = CGImageDestinationCreateWithURL(newImageURL as CFURL, UTType.heic.identifier as CFString, 2, nil)!

		let imageWidth = CGFloat(leftImg.width)
		let imageHeight = CGFloat(leftImg.height)
		let fovHorizontalDegrees: CGFloat = hFOV
		let fovHorizontalRadians = fovHorizontalDegrees * (.pi / 180)
		let focalLengthPixels = 0.5 * imageWidth / tan(0.5 * fovHorizontalRadians)

		let cameraIntrinsics: [CGFloat] = [
			focalLengthPixels, 0, imageWidth / 2,
			0, focalLengthPixels, imageHeight / 2,
			0, 0, 1
		]

		let rotationMatrix: [CGFloat] = [
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		]

		let positionMatrix: [CGFloat] = [ 0, 0, 0 ]

		let properties = [
			kCGImagePropertyGroups: [
				kCGImagePropertyGroupIndex: 0,
				kCGImagePropertyGroupType: kCGImagePropertyGroupTypeStereoPair,
				kCGImagePropertyGroupImageIndexLeft: 0,
				kCGImagePropertyGroupImageIndexRight: 1,
			],
			kCGImagePropertyHEIFDictionary: [
				kIIOMetadata_CameraModelKey: [
					kIIOCameraModel_Intrinsics: cameraIntrinsics as CFArray,
				],
				kIIOMetadata_CameraExtrinsicsKey: [
					kIIOCameraExtrinsics_CoordinateSystemID: 0 as CGFloat,
					kIIOCameraExtrinsics_Position: positionMatrix as CFArray,
					kIIOCameraExtrinsics_Rotation: rotationMatrix as CFArray,
				]
			]
		]

		CGImageDestinationAddImage(destination, leftImg, properties as CFDictionary)
		CGImageDestinationAddImage(destination, rightImg, properties as CFDictionary)
		CGImageDestinationFinalize(destination)
	}
}

SpatialPhotoCombiner.main()
