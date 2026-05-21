//
//  WebDAVResponse.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

public struct WebDAVResponse<Result: Sendable>: Sendable {

    public enum HeaderField: String, Sendable {
        case contentType = "Content-Type"
        case lastModified = "Last-Modified"
        case etag = "Etag"
        case contentLength = "Content-Length"
    }

    /// The response from the WebDAV server.
    public let result: Result

    /// The response status code from the WebDAV server.
    public let statusCode: Int

    /// The raw response headers from the WebDAV server.
    public let headers: [String: String]

    /// Retrieve a header from the response headers by key.
    public func value(forHeaderField key: String) -> String? {
        headers.first { $0.key.caseInsensitiveCompare(key) == .orderedSame }?.value
    }

    /// Retrieve a header from the response headers by `HeaderField`.
    public func value(forHeaderField key: HeaderField) -> String? {
        value(forHeaderField: key.rawValue)
    }

    public init(result: Result, statusCode: Int, headers: [String : String]) {
        self.result = result
        self.statusCode = statusCode
        self.headers = headers
    }
}
