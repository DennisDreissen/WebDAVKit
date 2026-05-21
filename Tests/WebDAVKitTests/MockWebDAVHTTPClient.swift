//
//  MockWebDAVHTTPClient.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 18/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation
import WebDAVKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class MockWebDAVHTTPClient: WebDAVHTTPClient, Sendable {

    typealias Handler = @Sendable (URLRequest) throws -> (Data, URLResponse)

    private let handler: Handler
    nonisolated(unsafe) var capturedBody: Data?

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedBody = request.httpBody
        return try handler(request)
    }

    func download(
        for request: URLRequest
    ) async throws -> (URL, URLResponse) {
        let (data, response) = try handler(request)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try data.write(to: url)

        capturedBody = data
        return (url, response)
    }

    func upload(
        for request: URLRequest,
        fromData data: Data,
        progressHandler: WebDAVHTTPClient.ProgressHandler?
    ) async throws -> (Data, URLResponse) {
        let simulatedSize = Int64(data.count / 3)
        progressHandler?(simulatedSize, simulatedSize, Int64(data.count))
        progressHandler?(simulatedSize, simulatedSize * 2, Int64(data.count))
        progressHandler?(simulatedSize, Int64(data.count), Int64(data.count))

        capturedBody = data
        return try handler(request)
    }

    func upload(
        for request: URLRequest,
        fromFile url: URL,
        progressHandler: WebDAVHTTPClient.ProgressHandler?
    ) async throws -> (Data, URLResponse) {
        let data = try Data(contentsOf: url)
        let simulatedSize = Int64(data.count / 3)
        progressHandler?(simulatedSize, simulatedSize, Int64(data.count))
        progressHandler?(simulatedSize, simulatedSize * 2, Int64(data.count))
        progressHandler?(simulatedSize, Int64(data.count), Int64(data.count))

        capturedBody = data
        return try handler(request)
    }
}
