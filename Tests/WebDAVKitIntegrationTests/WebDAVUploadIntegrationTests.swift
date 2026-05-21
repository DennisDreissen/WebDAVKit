//
//  WebDAVUploadIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 19/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func upload() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    let uploadResponse = try await client.upload(
        data: data,
        path: path
    )

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 201)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: path)
}

@Test
func upload_withProgressHandler() async throws {
    nonisolated(unsafe) var progressHandlerCalls: [Double] = []

    let client = createWebDAVClient()

    let data = testData(kilobytes: 100)
    let path = "\(#function).pdf"

    let uploadResponse = try await client.upload(
        data: data,
        path: path
    ) { progress in
        progressHandlerCalls.append(progress)
    }

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 201)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    #expect(progressHandlerCalls.last == 1.0)

    try await client.delete(path: path)
}

@Test
func upload_withExistingFile() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    try await client.upload(
        data: data,
        path: path
    )

    let uploadResponse = try await client.upload(
        data: data,
        path: path
    )

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 204)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: path)
}

@Test
func upload_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function)/\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 409)) {
        try await client.upload(
            data: data,
            path: path
        )
    }
}

@Test
func uploadFile() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

    let uploadResponse = try await client.upload(
        file: url,
        path: path
    )

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 201)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: path)
    try FileManager.default.removeItem(at: url)
}

@Test
func uploadFile_withProgressHandler() async throws {
    nonisolated(unsafe) var progressHandlerCalls: [Double] = []

    let client = createWebDAVClient()

    let data = testData(kilobytes: 100)
    let path = "\(#function).pdf"

    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

    let uploadResponse = try await client.upload(
        file: url,
        path: path
    ) { progress in
        progressHandlerCalls.append(progress)
    }

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 201)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    #expect(progressHandlerCalls.last == 1.0)

    try await client.delete(path: path)
    try FileManager.default.removeItem(at: url)
}

@Test
func uploadFile_withExistingFile() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

    try await client.upload(
        data: data,
        path: path
    )

    let uploadResponse = try await client.upload(
        file: url,
        path: path
    )

    let headResponse = try await client.head(path: path)

    #expect(uploadResponse.statusCode == 204)

    #expect(headResponse.statusCode == 200)
    #expect(headResponse.value(forHeaderField: .etag)?.isEmpty == false)
    #expect(headResponse.value(forHeaderField: .contentLength).map(Int.init) == data.count)
    #expect(headResponse.value(forHeaderField: .contentType) == "application/pdf")

    try await client.delete(path: path)
    try FileManager.default.removeItem(at: url)
}

@Test
func uploadFile_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function)/\(#function).pdf"

    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

    await #expect(throws: WebDAVError.responseError(statusCode: 409)) {
        try await client.upload(
            file: url,
            path: path
        )
    }

    try FileManager.default.removeItem(at: url)
}
