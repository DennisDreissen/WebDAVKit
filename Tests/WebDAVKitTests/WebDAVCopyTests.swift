//
//  WebDAVCopyTests.swift
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
func copy_withOverwritePolicy() async throws {
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

    let response = try await client.copy(
        sourcePath: "/Example/Image.jpg",
        destinationPath: "/Example/Image With Space.jpg",
        overwritePolicy: .overwrite
    )

    #expect(urlRequest.httpMethod == "COPY")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == nil)
    #expect(urlRequest.value(forHTTPHeaderField: "Destination") == "https://example.local/Example/Image%20With%20Space.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Overwrite") == "T")

    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func copy_withFailPolicy() async throws {
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

    let response = try await client.copy(
        sourcePath: "/Example/Image.jpg",
        destinationPath: "/Example/Image With Space.jpg",
        overwritePolicy: .fail
    )

    #expect(urlRequest.httpMethod == "COPY")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == nil)
    #expect(urlRequest.value(forHTTPHeaderField: "Destination") == "https://example.local/Example/Image%20With%20Space.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Overwrite") == "F")

    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func copy_withCustomHeaders() async throws {
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

    let response = try await client.copy(
        sourcePath: "/Example/Image.jpg",
        destinationPath: "/Example/Image With Space.jpg",
        overwritePolicy: .fail,
        customHeaders: [
            "x-custom-header": "custom-header-value"
        ]
    )

    #expect(urlRequest.httpMethod == "COPY")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == nil)
    #expect(urlRequest.value(forHTTPHeaderField: "Destination") == "https://example.local/Example/Image%20With%20Space.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Overwrite") == "F")
    #expect(urlRequest.value(forHTTPHeaderField: "x-custom-header") == "custom-header-value")
    
    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func copy_returnsInvalidStatusCode() async throws {
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
        try await client.copy(
            sourcePath: "/Example/Image.jpg",
            destinationPath: "/Example/Image With Space.jpg",
            overwritePolicy: .fail
        )
    }
}
