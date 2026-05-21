//
//  WebDAVHeadIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func head() async throws {
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
func head_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let path = "\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.head(path: path)
    }
}
