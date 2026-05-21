//
//  WebDAVListIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func list() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let file01Path = "\(#function).pdf"
    let directory01Path = "/\(#function)/"
    let file02Path = "\(#function)/\(#function).pdf"

    try await client.upload(
        data: data,
        path: file01Path
    )

    try await client.createDirectory(path: directory01Path)

    try await client.upload(
        data: data,
        path: file02Path
    )

    let listResponse = try await client.list(path: "/")

    #expect(listResponse.statusCode == 207)

    let root = listResponse.result.first { $0.path == "/" }
    #expect(root != nil)
    #expect(root?.isDirectory == true)
    #expect(root?.contentType == "httpd/unix-directory")
    #expect(root?.size == nil)

    let file = listResponse.result.first { $0.name == file01Path }
    #expect(file != nil)
    #expect(file?.isDirectory == false)
    #expect(file?.size ?? 0 == data.count)
    #expect(file?.contentType == "application/pdf")

    let directory = listResponse.result.first { $0.path == directory01Path }
    #expect(directory != nil)
    #expect(directory?.isDirectory == true)
    #expect(directory?.contentType == "httpd/unix-directory")
    #expect(directory?.size == nil)


    try await client.delete(path: file01Path)
    try await client.delete(path: directory01Path)
}

@Test
func list_withTargetDepth() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    try await client.upload(
        data: data,
        path: path
    )

    let listResponse = try await client.list(
        path: path,
        depth: .target
    )

    #expect(listResponse.statusCode == 207)
    #expect(listResponse.result.count == 1)

    let file = listResponse.result.first { $0.name == path }
    #expect(file != nil)
    #expect(file?.isDirectory == false)
    #expect(file?.size ?? 0 == data.count)
    #expect(file?.contentType == "application/pdf")


    try await client.delete(path: path)
}

@Test
func list_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let path = "\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.list(path: path)
    }
}
