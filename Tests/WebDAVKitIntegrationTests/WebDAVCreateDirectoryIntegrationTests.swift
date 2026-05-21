//
//  WebDAVCreateDirectoryIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 19/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func createDirectory() async throws {
    let client = createWebDAVClient()

    let path = "\(#function)/"

    let createDirectoryResponse = try await client.createDirectory(path: path)

    #expect(createDirectoryResponse.statusCode == 201)

    try await client.delete(path: path)
}

@Test
func createDirectory_withExistingDirectory() async throws {
    let client = createWebDAVClient()

    let path = "\(#function)/"

    try await client.createDirectory(path: path)

    await #expect(throws: WebDAVError.responseError(statusCode: 405)) {
        try await client.createDirectory(path: path)
    }

    try await client.delete(path: path)
}

@Test
func createDirectory_withInvalidDirectory() async throws {
    let client = createWebDAVClient()

    let path = "\(#function)/\(#function)/"

    await #expect(throws: WebDAVError.responseError(statusCode: 409)) {
        try await client.createDirectory(path: path)
    }
}
