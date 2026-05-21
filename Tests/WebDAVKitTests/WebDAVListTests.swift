//
//  WebDAVListTests.swift
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
func list() async throws {
    nonisolated(unsafe) var urlRequest: URLRequest!

    let httpClient = MockWebDAVHTTPClient { request in
        urlRequest = request

        return (
            listData,
            HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "application/xml",
                    "test-header": "test-value"
                ]
            )!
        )
    }

    let client = createWebDAVClient(httpClient: httpClient)

    let response = try await client.list(
        path: "/Example"
    )

    #expect(urlRequest.httpMethod == "PROPFIND")
    #expect(urlRequest.url?.absoluteString == "https://example.local/Example")
    #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == exampleAuthorizationHeader)
    #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/xml")
    
    #expect(response.value(forHeaderField: "test-header") == "test-value")
    #expect(response.value(forHeaderField: .contentType) == "application/xml")

    #expect(
        response.result ==
        [
            WebDAVResource(
                eTag: "\"00000-11111\"",
                name: "Example",
                path: "/Example/",
                size: nil,
                contentType: "httpd/unix-directory",
                lastModified: try? Date("2026-05-18T20:00:00+0000", strategy: .iso8601),
                isDirectory: true
            ),
            WebDAVResource(
                eTag: "\"00000-22222\"",
                name: "Image.jpg",
                path: "/Example/Image.jpg",
                size: 10485760,
                contentType: "image/jpeg",
                lastModified: try? Date("2026-05-18T21:00:00+0000", strategy: .iso8601),
                isDirectory: false
            )
        ]
    )
}

@Test
func list_withInvalidXML() async throws {
    let httpClient = MockWebDAVHTTPClient { request in
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

    await #expect(throws: WebDAVError.decodingResponseFailed) {
        try await client.list(
            path: "/Example"
        )
    }
}

@Test
func list_returnsInvalidStatusCode() async throws {
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
        try await client.list(
            path: "/Example"
        )
    }
}

private let listData = """
<?xml version="1.0" encoding="utf-8"?>
<D:multistatus
    xmlns:D="DAV:"
    xmlns:ns0="DAV:">
    <D:response
        xmlns:lp1="DAV:"
        xmlns:lp2="http://apache.org/dav/props/"
        xmlns:g0="DAV:">
        <D:href>/Example/</D:href>
        <D:propstat>
            <D:prop>
                <lp1:getetag>"00000-11111"</lp1:getetag>
                <D:getcontenttype>httpd/unix-directory</D:getcontenttype>
                <lp1:getlastmodified>Mon, 18 May 2026 20:00:00 GMT</lp1:getlastmodified>
                <lp1:resourcetype>
                    <D:collection/>
                </lp1:resourcetype>
            </D:prop>
            <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
        <D:propstat>
            <D:prop>
                <g0:displayname/>
                <g0:getcontentlength/>
            </D:prop>
            <D:status>HTTP/1.1 404 Not Found</D:status>
        </D:propstat>
    </D:response>
    <D:response
        xmlns:lp1="DAV:"
        xmlns:lp2="http://apache.org/dav/props/"
        xmlns:g0="DAV:">
        <D:href>/Example/Image.jpg</D:href>
        <D:propstat>
            <D:prop>
                <lp1:getetag>"00000-22222"</lp1:getetag>
                <lp1:getcontentlength>10485760</lp1:getcontentlength>
                <D:getcontenttype>image/jpeg</D:getcontenttype>
                <lp1:getlastmodified>Mon, 18 May 2026 21:00:00 GMT</lp1:getlastmodified>
                <lp1:resourcetype/>
            </D:prop>
            <D:status>HTTP/1.1 200 OK</D:status>
        </D:propstat>
        <D:propstat>
            <D:prop>
                <g0:displayname/>
            </D:prop>
            <D:status>HTTP/1.1 404 Not Found</D:status>
        </D:propstat>
    </D:response>
</D:multistatus>
""".data(using: .utf8)!
