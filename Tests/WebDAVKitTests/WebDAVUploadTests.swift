//
//  WebDAVUploadTests.swift
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
func upload() async throws {
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

    let response = try await client.upload(
        data: someData,
        path: "/Example/Image.jpg"
    )

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Length") == "\(someData.count)")
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")

    #expect(httpClient.capturedBody == someData)
    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func upload_withCustomHeaders() async throws {
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

    let response = try await client.upload(
        data: someData,
        path: "/Example/Image.jpg",
        customHeaders: [
            "x-custom-header": "custom-header-value"
        ]
    )

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Length") == "\(someData.count)")
    #expect(urlRequest.value(forHTTPHeaderField: "x-custom-header") == "custom-header-value")

    #expect(httpClient.capturedBody == someData)
    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func upload_withProgressHandler() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!
    nonisolated(unsafe) var progressHandlerCalls: [Double] = []

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

    let response = try await client.upload(
        data: someData,
        path: "/Example/Image.jpg"
    ) { progress in
        progressHandlerCalls.append(progress)
    }

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Length") == "\(someData.count)")
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")

    #expect(httpClient.capturedBody == someData)
    #expect(response.value(forHeaderField: "test-header") == "test-value")

    #expect(progressHandlerCalls.first ?? .infinity < 1.0)
    #expect(progressHandlerCalls.last == 1.0)
}

@Test
func upload_returnsInvalidStatusCode() async throws {
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
        try await client.upload(
            data: someData,
            path: "/Example/Image.jpg"
        )
    }
}

@Test
func uploadFile() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!

    let data = testData(kilobytes: 10)
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

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

    let response = try await client.upload(
        file: url,
        path: "/Example/Image.jpg"
    )

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")

    #expect(httpClient.capturedBody == data)
    #expect(response.value(forHeaderField: "test-header") == "test-value")
}

@Test
func uploadFile_withCustomHeaders() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!

    let data = testData(kilobytes: 10)
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

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

    let response = try await client.upload(
        file: url,
        path: "/Example/Image.jpg",
        customHeaders: [
            "x-custom-header": "custom-header-value"
        ]
    )

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")
    #expect(urlRequest.value(forHTTPHeaderField: "x-custom-header") == "custom-header-value")

    #expect(httpClient.capturedBody == data)
    #expect(response.value(forHeaderField: "test-header") == "test-value")

    try FileManager.default.removeItem(at: url)
}

@Test
func uploadFile_withProgressHandler() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!
    nonisolated(unsafe) var progressHandlerCalls: [Double] = []

    let data = testData(kilobytes: 10)
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

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

    let response = try await client.upload(
        file: url,
        path: "/Example/Image.jpg"
    ) { progress in
        progressHandlerCalls.append(progress)
    }

    #expect(urlRequest.httpMethod == "PUT")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example/Image.jpg")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")

    #expect(httpClient.capturedBody == data)
    #expect(response.value(forHeaderField: "test-header") == "test-value")

    #expect(progressHandlerCalls.first ?? .infinity < 1.0)
    #expect(progressHandlerCalls.last == 1.0)

    try FileManager.default.removeItem(at: url)
}

@Test
func uploadFile_returnsInvalidStatusCode() async throws {
    let data = testData(kilobytes: 10)
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try data.write(to: url)

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
        try await client.upload(
            file: url,
            path: "/Example/Image.jpg"
        )
    }

    try FileManager.default.removeItem(at: url)
}
