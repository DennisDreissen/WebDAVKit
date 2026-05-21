//
//  Helpers.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 18/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation
import WebDAVKit

let someData = "some data".data(using: .utf8)!
let exampleAuthorizationHeader = "Basic \(Data("username:password".utf8).base64EncodedString())"

func testData(kilobytes: Int) -> Data {
    var data = Data(count: kilobytes * 1024)
    data.withUnsafeMutableBytes {
        arc4random_buf($0.baseAddress!, $0.count)
    }
    return data
}

func createWebDAVClient(
    baseURL: String = "https://example.local",
    httpClient: WebDAVHTTPClient
) -> WebDAVClient {
    WebDAVClient(
        baseURL: URL(string: baseURL)!,
        credentials: WebDAVCredentials(
            username: "username",
            password: "password"
        ),
        httpClient: httpClient
    )
}

extension AsyncThrowingStream where Element == Data {

    func collect() async throws -> Data {
        try await reduce(into: Data()) { @Sendable in $0.append($1) }
    }
}
