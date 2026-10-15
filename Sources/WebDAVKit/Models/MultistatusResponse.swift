//
//  MultistatusResponse.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

struct MultistatusResponse: Decodable {

    let response: [Response]

    struct Response: Decodable {

        let href: String
        let propstat: [Propstat]?
        let status: String?

        struct Propstat: Decodable {

            let status: String
            let prop: Prop

            struct Prop: Decodable {

                let getetag: String?
                let getcontenttype: String?
                let getcontentlength: String?
                let getlastmodified: String?
                let displayname: String?
                let resourcetype: ResourceType?

                struct ResourceType: Decodable {

                    let collection: EmptyElement?

                    struct EmptyElement: Decodable {}
                }
            }
        }
    }
}

extension MultistatusResponse {

    var webDAVObjects: [WebDAVResource] {
        get throws {
            try response.map { resource in
                let successful = (resource.propstat ?? []).filter {
                    Self.statusCode($0.status).map { (200..<300).contains($0) } ?? false
                }.map(\.prop)

                // A failed or absent resourcetype cannot establish that an entry is a file.
                guard let resourceType = successful.compactMap(\.resourcetype).first else {
                    throw WebDAVError.resourcePropertiesUnavailable
                }

                let displayName = successful.compactMap(\.displayname).first { !$0.isEmpty }
                return WebDAVResource(
                    eTag: successful.compactMap(\.getetag).first,
                    name: displayName ?? URL(string: resource.href)?.lastPathComponent,
                    path: resource.href,
                    size: successful.compactMap(\.getcontentlength).compactMap(Int64.init).first,
                    contentType: successful.compactMap(\.getcontenttype).first,
                    lastModified: successful.compactMap(\.getlastmodified)
                        .compactMap { DateFormatter.rfc2822.date(from: $0) }.first,
                    isDirectory: resourceType.collection != nil
                )
            }
        }
    }

    private static func statusCode(_ status: String) -> Int? {
        let parts = status.split(whereSeparator: \.isWhitespace)
        guard parts.count >= 2, parts[0].hasPrefix("HTTP/"), parts[1].count == 3 else { return nil }
        return Int(parts[1])
    }
}
