//
//  WebDAVError.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

public enum WebDAVError: Error, Sendable, Equatable {

    /// The response from the server is not valid.
    case invalidResponse

    /// Decoding the response body failed.
    case decodingResponseFailed

    /// The server returned an error. Contains the status code returned by the WebDAV server.
    case responseError(statusCode: Int)
}
