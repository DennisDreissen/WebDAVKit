//
//  WebDAVDataIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func data() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    try await client.upload(
        data: data,
        path: path
    )

    let response = try await client.data(path: path)

    #expect(response.statusCode == 200)
    #expect(response.value(forHeaderField: .contentLength).map(Int.init) == response.result.count)
    #expect(response.value(forHeaderField: .contentType) == "application/pdf")
    #expect(response.result == data)

    try await client.delete(path: path)
}

@Test
func data_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let path = "\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.data(path: path)
    }
}
