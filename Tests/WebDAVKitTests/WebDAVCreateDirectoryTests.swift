//
//  WebDAVCreateDirectoryTests.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 18/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Testing
import Foundation
@testable import WebDAVKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@Test
func createDirectory() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!

    let httpClient = MockWebDAVHTTPClient { request in
        urlRequest = request

        return (
            someData,
            HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "test-header": "test-value"
                ]
            )!
        )
    }

    let client = createWebDAVClient(httpClient: httpClient)

    let response = try await client.createDirectory(
        path: "/Example/Dir"
    )

    #expect(urlRequest.httpMethod == "MKCOL")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Dir")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == nil)

    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func createDirectory_withCustomHeaders() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!

    let httpClient = MockWebDAVHTTPClient { request in
        urlRequest = request

        return (
            someData,
            HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "test-header": "test-value"
                ]
            )!
        )
    }

    let client = createWebDAVClient(httpClient: httpClient)

    let response = try await client.createDirectory(
        path: "/Example/Dir",
        customHeaders: [
            "x-custom-header": "custom-header-value"
        ]
    )

    #expect(urlRequest.httpMethod == "MKCOL")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Dir")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == nil)
    #expect(urlRequest.value(forHTTPHeaderField: "x-custom-header") == "custom-header-value")
    
    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func createDirectory_invalidStatusCode() async throws {
    let httpClient = MockWebDAVHTTPClient { request in
        return (
            someData,
            HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: [:]
            )!
        )
    }

    let client = createWebDAVClient(httpClient: httpClient)

    await #expect(throws: WebDAVError.responseError(statusCode: 500)) {
        try await client.createDirectory(
            path: "/Example/Dir"
        )
    }
}
