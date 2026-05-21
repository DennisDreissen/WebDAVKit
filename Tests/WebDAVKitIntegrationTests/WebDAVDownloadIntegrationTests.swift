//
//  WebDAVDownloadIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 21/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func download() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    try await client.upload(
        data: data,
        path: path
    )

    let response = try await client.download(path: path)
    let responseData = try Data(contentsOf: response.result)

    #expect(response.statusCode == 200)
    #expect(response.value(forHeaderField: .contentLength).map(Int.init) == responseData.count)
    #expect(response.value(forHeaderField: .contentType) == "application/pdf")
    #expect(responseData == data)

    try await client.delete(path: path)
}

@Test
func download_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let path = "\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.data(path: path)
    }
}
