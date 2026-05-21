//
//  WebDAVDeleteIntegrationTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 20/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

@Test
func delete() async throws {
    let client = createWebDAVClient()

    let data = testData(kilobytes: 50)
    let path = "\(#function).pdf"

    try await client.upload(
        data: data,
        path: path
    )

    let destinationHeadResponse = try await client.head(path: path)

    let removeResponse = try await client.delete(path: path)

    #expect(destinationHeadResponse.statusCode == 200)
    #expect(removeResponse.statusCode == 204)
}

@Test
func delete_withInvalidPath() async throws {
    let client = createWebDAVClient()

    let path = "\(#function).pdf"

    await #expect(throws: WebDAVError.responseError(statusCode: 404)) {
        try await client.delete(path: path)
    }
}
