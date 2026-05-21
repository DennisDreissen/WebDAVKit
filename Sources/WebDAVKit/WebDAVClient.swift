//
//  WebDAVClient.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation
import XMLCoder

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct WebDAVClient: Sendable {

    /// Base URL of the WebDAV server.
    public let baseURL: URL

    /// Credentials provider to authenticate requests.
    public let credentials: WebDAVCredentialsProvider?

    /// HTTP client used by WebDAVClient.
    public let httpClient: WebDAVHTTPClient

    /// Create a WebDAV client.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL of the WebDAV server.
    ///   - credentials: The credentials used to make requests.
    ///   - httpClient: The http client used to execute the requests.
    public init(
        baseURL: URL,
        credentials: WebDAVCredentialsProvider?,
        httpClient: WebDAVHTTPClient = WebDAVDefaultHTTPClient()
    ) {
        self.baseURL = baseURL
        self.credentials = credentials
        self.httpClient = httpClient
    }

    /// Get details of a resource or a directory.
    ///
    /// - Parameters:
    ///   - path: The path of the resource to get the details of.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    @discardableResult
    public func head(
        path: String,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Void> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "HEAD",
            customHeaders: customHeaders
        )

        let (_, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Get details of a resource or a directory of resources.
    ///
    /// - Parameters:
    ///   - path: The path of the resource to get the details of.
    ///   - depth: Whether to return details for just the resource or include its immediate children.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    public func list(
        path: String,
        depth: WebDAVListDepth = .targetAndChildren,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<[WebDAVResource]> {
        var request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "PROPFIND",
            customHeaders: customHeaders
        )

        request.setValue(depth.value, forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")

        request.httpBody = """
        <?xml version="1.0" encoding="UTF-8"?>
            <d:propfind xmlns:d="DAV:">
                <d:prop>
                    <d:getetag/>
                    <d:displayname/>
                    <d:getcontentlength/>
                    <d:getcontenttype/>
                    <d:getlastmodified/>
                    <d:resourcetype/>
                </d:prop>
            </d:propfind>
        """.data(using: .utf8)

        let (data, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: try decode(
                MultistatusResponse.self,
                from: data
            ).webDAVObjects,
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Download a resource.
    ///
    /// - Parameters:
    ///   - path: The path of the resource to download.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    public func data(
        path: String,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Data> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "GET",
            customHeaders: customHeaders
        )

        let (data, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: data,
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Download a resource to the disk.
    ///
    /// - Parameters:
    ///   - path: The path of the resource to download.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    public func download(
        path: String,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<URL> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "GET",
            customHeaders: customHeaders
        )

        let (url, http) = try await executeDownloadRequest(request)

        return WebDAVResponse(
            result: url,
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Upload a resource.
    ///
    /// - Parameters:
    ///   - data: The resource data.
    ///   - path: The path of the resource to create.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    ///   - progressHandler: A callback that reports the upload progress.
    @discardableResult
    public func upload(
        data: Data,
        path: String,
        customHeaders: [String: String] = [:],
        progressHandler: (@Sendable (Double) -> Void)? = nil
    ) async throws -> WebDAVResponse<Void> {
        var request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "PUT",
            contentType: "application/octet-stream",
            customHeaders: customHeaders,
            body: data
        )

        request.httpBody = nil

        let (_, http) = try await executeUploadRequest(request, data: data, progressHandler: progressHandler)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Upload a resource.
    ///
    /// - Parameters:
    ///   - file: The resource file.
    ///   - path: The path of the resource to create.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    ///   - progressHandler: A callback that reports the upload progress.
    @discardableResult
    public func upload(
        file url: URL,
        path: String,
        customHeaders: [String: String] = [:],
        progressHandler: (@Sendable (Double) -> Void)? = nil
    ) async throws -> WebDAVResponse<Void> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "PUT",
            contentType: "application/octet-stream",
            customHeaders: customHeaders
        )

        let (_, http) = try await executeUploadRequest(request, file: url, progressHandler: progressHandler)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Create a directory.
    ///
    /// - Parameters:
    ///   - path: The path where to create the directory.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    @discardableResult
    public func createDirectory(
        path: String,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Void> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "MKCOL",
            customHeaders: customHeaders
        )

        let (_, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Move a resource to a new location.
    ///
    /// - Parameters:
    ///   - sourcePath: The current path of the resource to move.
    ///   - destinationPath: The path to move the resource to.
    ///   - overwrite: Whether to overwrite if a resource at the destination path already exists.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    @discardableResult
    public func move(
        sourcePath: String,
        destinationPath: String,
        overwritePolicy: WebDAVOverwritePolicy,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Void> {
        var request = createRequest(
            url: baseURL.appendingPathComponent(sourcePath),
            method: "MOVE",
            customHeaders: customHeaders
        )

        request.setValue(
            baseURL.appendingPathComponent(destinationPath).absoluteString,
            forHTTPHeaderField: "Destination"
        )
        request.setValue(
            overwritePolicy.value,
            forHTTPHeaderField: "Overwrite"
        )

        let (_, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Copy a resource to a different location.
    ///
    /// - Parameters:
    ///   - sourcePath: The current path of the resource to copy.
    ///   - destinationPath: The path to copy the resource to.
    ///   - overwrite: Whether to overwrite if a resource at the destination path already exists.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    @discardableResult
    public func copy(
        sourcePath: String,
        destinationPath: String,
        overwritePolicy: WebDAVOverwritePolicy,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Void> {
        var request = createRequest(
            url: baseURL.appendingPathComponent(sourcePath),
            method: "COPY",
            customHeaders: customHeaders
        )

        request.setValue(
            baseURL.appendingPathComponent(destinationPath).absoluteString,
            forHTTPHeaderField: "Destination"
        )
        request.setValue(
            overwritePolicy.value,
            forHTTPHeaderField: "Overwrite"
        )

        let (_, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }

    /// Delete a resource.
    ///
    /// - Parameters:
    ///   - path: The path of the resource to delete.
    ///   - customHeaders: Additional headers to include in the request to the WebDAV server.
    @discardableResult
    public func delete(
        path: String,
        customHeaders: [String: String] = [:]
    ) async throws -> WebDAVResponse<Void> {
        let request = createRequest(
            url: baseURL.appendingPathComponent(path),
            method: "DELETE",
            customHeaders: customHeaders
        )

        let (_, http) = try await executeRequest(request)

        return WebDAVResponse(
            result: (),
            statusCode: http.statusCode,
            headers: http.stringHeaders
        )
    }
}

private extension WebDAVClient {

    func createRequest(
        url: URL,
        method: String,
        contentType: String? = nil,
        customHeaders: [String: String] = [:],
        body: Data? = nil
    ) -> URLRequest {
        let body = body ?? Data()

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let authorizationHeader = getAuthorizationHeader() {
            request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        }

        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        customHeaders.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }

        request.httpBody = body.isEmpty ? nil : body

        if !body.isEmpty {
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        }

        return request
    }

    @discardableResult
    func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await httpClient.data(for: request)

        return (data, try httpURLResponse(from: urlResponse))
    }

    @discardableResult
    func executeDownloadRequest(_ request: URLRequest) async throws -> (URL, HTTPURLResponse) {
        let (url, urlResponse) = try await httpClient.download(for: request)

        return (url, try httpURLResponse(from: urlResponse))
    }

    @discardableResult
    func executeUploadRequest(
        _ request: URLRequest,
        data: Data,
        progressHandler: (@Sendable (Double) -> Void)? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await httpClient.upload(
            for: request,
            fromData: data
        ) { _, totalBytesSent, totalBytesExpectedToSend in
            progressHandler?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
        }

        return (data, try httpURLResponse(from: urlResponse))
    }

    @discardableResult
    func executeUploadRequest(
        _ request: URLRequest,
        file url: URL,
        progressHandler: (@Sendable (Double) -> Void)? = nil
    ) async throws -> (Data, HTTPURLResponse) {
        let (data, urlResponse) = try await httpClient.upload(
            for: request,
            fromFile: url
        ) { _, totalBytesSent, totalBytesExpectedToSend in
            progressHandler?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
        }

        return (data, try httpURLResponse(from: urlResponse))
    }

    func getAuthorizationHeader() -> String? {
        guard let credentials else {
            return nil
        }

        let encoded = Data("\(credentials.username):\(credentials.password)".utf8).base64EncodedString()
        return "Basic \(encoded)"
    }

    func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {
        do {
            let decoder = XMLDecoder()
            decoder.shouldProcessNamespaces = true
            decoder.trimValueWhitespaces = true
            return try decoder.decode(type.self, from: data)
        } catch {
            throw WebDAVError.decodingResponseFailed
        }
    }

    func httpURLResponse(from urlResponse: URLResponse) throws -> HTTPURLResponse {
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }

        guard (200..<300).contains(httpUrlResponse.statusCode) else {
            throw WebDAVError.responseError(statusCode: httpUrlResponse.statusCode)
        }

        return httpUrlResponse
    }
}
