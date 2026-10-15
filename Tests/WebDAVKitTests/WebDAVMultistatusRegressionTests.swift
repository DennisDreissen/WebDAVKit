import Foundation
import Testing
@testable import WebDAVKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@Suite
struct WebDAVMultistatusRegressionTests {
    @Test(arguments: [false, true])
    func mergesSuccessfulGroupsInEitherOrder(reversed: Bool) async throws {
        let groups = [
            propstat("<d:displayname>Music</d:displayname>"),
            propstat("<d:resourcetype><d:collection/></d:resourcetype><d:getetag>directory-etag</d:getetag>"),
        ]
        let successful = reversed ? Array(groups.reversed()) : groups
        let failed = propstat("<d:displayname>Wrong</d:displayname><d:resourcetype/>", status: "HTTP/1.1 404 Not Found")
        let resources = try await list(response(successful.joined() + failed))
        let resource = try #require(resources.first)
        #expect(resources.count == 1)
        #expect(resource.name == "Music")
        #expect(resource.isDirectory)
        #expect(resource.eTag == "directory-etag")
    }

    @Test(arguments: ["d", "D", "custom", ""])
    func acceptsNamespacePrefixes(prefix: String) async throws {
        let body = response(propstat("<d:resourcetype/><d:getcontentlength>42</d:getcontentlength>"))
        let xml = prefix.isEmpty
            ? body.replacingOccurrences(of: "d:", with: "").replacingOccurrences(of: "xmlns:d", with: "xmlns")
            : body.replacingOccurrences(of: "d:", with: prefix + ":").replacingOccurrences(of: "xmlns:d", with: "xmlns:" + prefix)
        let file = try #require(try await list(xml).first)
        #expect(!file.isDirectory)
        #expect(file.size == 42)
    }

    @Test(arguments: ["HTTP/1.1 403 Forbidden", "HTTP/1.1 404 Error 200", "HTTP/1.1 1200 Invalid"])
    func doesNotTurnFailedPropertiesIntoAFile(status: String) async throws {
        await #expect(throws: WebDAVError.resourcePropertiesUnavailable) {
            try await list(response(propstat("<d:resourcetype/>", status: status)))
        }
    }

    @Test
    func rejectsUnknownResourceTypeEvenWhenOtherMetadataSucceeded() async throws {
        let groups = propstat("<d:displayname>Restricted</d:displayname>")
            + propstat("<d:resourcetype/>", status: "HTTP/1.1 403 Forbidden")
        await #expect(throws: WebDAVError.resourcePropertiesUnavailable) {
            try await list(response(groups))
        }
    }

    @Test
    func reportsResponseLevelFailure() async throws {
        await #expect(throws: WebDAVError.resourcePropertiesUnavailable) {
            try await list(response("<d:status>HTTP/1.1 404 Not Found</d:status>"))
        }
    }

    @Test
    func permitsAnEmptyMultistatus() async throws {
        let resources = try await list("<d:multistatus xmlns:d=\"DAV:\"/>")
        #expect(resources.isEmpty)
    }

    private func propstat(_ properties: String, status: String = "HTTP/1.1 200 OK") -> String {
        "<d:propstat><d:prop>\(properties)</d:prop><d:status>\(status)</d:status></d:propstat>"
    }

    private func response(_ groups: String) -> String {
        "<d:multistatus xmlns:d=\"DAV:\"><d:response><d:href>/dav/music/</d:href>\(groups)</d:response></d:multistatus>"
    }

    private func list(_ xml: String) async throws -> [WebDAVResource] {
        let client = createWebDAVClient(httpClient: MockWebDAVHTTPClient { request in
            (Data(xml.utf8), HTTPURLResponse(url: request.url!, statusCode: 207, httpVersion: nil, headerFields: nil)!)
        })
        return try await client.list(path: "dav").result
    }
}
