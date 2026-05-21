//
//  WebDAVMoveIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func move() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let sourcePath = "\(#function).pdf"
    let destinationPath = "\(#function)_moved.pdf"

    try await client.upload(
        data: data,
        path: sourcePath
    )

    let moveResponse = try await client.move(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        overwritePolicy: .overwrite
    )

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.head(path: sourcePath)
    }

    let destinationHeadResponse = try await client.head(path: destinationPath)

    #expect(moveResponse.statusCode == 201)

    #expect(destinationHeadResponse.statusCode == 200)
    #expect(destinationHeadResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(destinationHeadResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(destinationHeadResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: destinationPath)
}

@Test
func move_withFailOverwritePolicy() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let sourcePath = "\(#function).pdf"
    let destinationPath = "\(#function)_moved.pdf"

    try await client.upload(
        data: data,
        path: sourcePath
    )

    try await client.upload(
        data: data,
        path: destinationPath
    )

    await #expect(throws: WebDAVError.responseError(statusCode: 412)) {
        try await client.move(
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            overwritePolicy: .fail
        )
    }

    try await client.delete(path: sourcePath)
    try await client.delete(path: destinationPath)
}

@Test
func move_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let sourcePath = "\(#function).pdf"
    let destinationPath = "\(#function)/\(#function)_moved.pdf"

    try await client.upload(
        data: data,
        path: sourcePath
    )

    // The Apache server returns a 500 here for some reason, unlike COPY which returns the expected 409.
    await #expect(throws: WebDAVError.responseError(statusCode: 500)) {
        try await client.move(
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            overwritePolicy: .overwrite
        )
    }

    try await client.delete(path: sourcePath)
}
