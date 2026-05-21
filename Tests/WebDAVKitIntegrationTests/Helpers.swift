//
//  Helpers.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 18/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation
import WebDAVKit

func testData(kilobytes: Int) -> Data {
    var data = Data(count: kilobytes * 1024)
    data.withUnsafeMutableBytes {
        arc4random_buf($0.baseAddress!, $0.count)
    }
    return data
}

func testData(megabytes: Int) -> Data {
    testData(kilobytes: megabytes * 1024)
}

func createWebDAVClient() -> WebDAVClient {
    let baseUrl = URL(string:
        ProcessInfo.processInfo.environment["WEBDAV_BASE_URL"] ?? "http://localhost:29190"
    )!

    return WebDAVClient(
        baseURL: baseUrl,
        credentials: WebDAVCredentials(
            username: "username",
            password: "password"
        )
    )
}

extension AsyncThrowingStream where Element == Data {

    func collect() async throws -> Data {
        try await reduce(into: Data()) { @Sendable in $0.append($1) }
    }
}
