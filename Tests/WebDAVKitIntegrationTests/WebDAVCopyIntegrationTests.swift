//
//  WebDAVCopyIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func copy() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let sourcePath = "\(#function).pdf"
    let destinationPath = "\(#function)_moved.pdf"

    try await client.upload(
        data: data,
        path: sourcePath
    )

    let copyResponse = try await client.copy(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        overwritePolicy: .overwrite
    )

    let sourceHeadResponse = try await client.head(path: sourcePath)
    let destinationHeadResponse = try await client.head(path: destinationPath)

    #expect(copyResponse.statusCode == 201)

    #expect(sourceHeadResponse.statusCode == 200)
    #expect(sourceHeadResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(sourceHeadResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(sourceHeadResponse.value(forHeaderField: .contentType) == "application/pdf")

    #expect(destinationHeadResponse.statusCode == 200)
    #expect(destinationHeadResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(destinationHeadResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(destinationHeadResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: sourcePath)
    try await client.delete(path: destinationPath)
}

@Test
func copy_withFailOverwritePolicy() async throws {
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
        try await client.copy(
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            overwritePolicy: .fail
        )
    }

    try await client.delete(path: sourcePath)
    try await client.delete(path: destinationPath)
}

@Test
func copy_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let sourcePath = "\(#function).pdf"
    let destinationPath = "\(#function)/\(#function)_moved.pdf"

    try await client.upload(
        data: data,
        path: sourcePath
    )

    await #expect(throws: WebDAVError.responseError(statusCode: 409)) {
        try await client.copy(
            sourcePath: sourcePath,
            destinationPath: destinationPath,
            overwritePolicy: .overwrite
        )
    }

    try await client.delete(path: sourcePath)
}
