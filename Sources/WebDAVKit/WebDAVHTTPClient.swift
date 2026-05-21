//
//  WebDAVHTTPClient.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol WebDAVHTTPClient: Sendable {

    typealias ProgressHandler = @Sendable (
        _ bytesSent: Int64,
        _ totalBytesSent: Int64,
        _ totalBytesExpectedToSend: Int64
    ) -> Void

    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)

    func download(
        for request: URLRequest
    ) async throws -> (URL, URLResponse)

    func upload(
        for request: URLRequest,
        fromData data: Data,
        progressHandler: ProgressHandler?
    ) async throws -> (Data, URLResponse)

    func upload(
        for request: URLRequest,
        fromFile url: URL,
        progressHandler: ProgressHandler?
    ) async throws -> (Data, URLResponse)
}

public final class WebDAVDefaultHTTPClient: WebDAVHTTPClient, Sendable {

    /// The URLSession instance used to make HTTP requests.
    let session: URLSession

    public init(configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(
            configuration: configuration,
            delegate: nil,
            delegateQueue: nil
        )
    }

    deinit {
        session.finishTasksAndInvalidate()
    }

    public func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }

    public func download(
        for request: URLRequest
    ) async throws -> (URL, URLResponse) {
        try await session.download(for: request)
    }

    public func upload(
        for request: URLRequest,
        fromData data: Data,
        progressHandler: ProgressHandler?
    ) async throws -> (Data, URLResponse) {
        let delegate = progressHandler.map { WebDAVUploadProgressDelegate(progressHandler: $0) }
        return try await session.upload(for: request, from: data, delegate: delegate)
    }

    public func upload(
        for request: URLRequest,
        fromFile url: URL,
        progressHandler: ProgressHandler?
    ) async throws -> (Data, URLResponse) {
        let delegate = progressHandler.map { WebDAVUploadProgressDelegate(progressHandler: $0) }
        return try await session.upload(for: request, fromFile: url, delegate: delegate)
    }
}

final class WebDAVUploadProgressDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {

    let progressHandler: WebDAVHTTPClient.ProgressHandler

    init(progressHandler: @escaping WebDAVHTTPClient.ProgressHandler) {
        self.progressHandler = progressHandler
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        progressHandler(bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }
}
