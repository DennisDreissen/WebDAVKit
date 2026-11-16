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
        let propstat: [Propstat]

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
        response.map { item in
            let props = item.propstat
                .filter { $0.status.isSuccessfulHTTPStatus }
                .map(\.prop)

            let displayName = props.compactMap(\.displayname).first { !$0.isEmpty }
            let name = displayName ?? URL(string: item.href)?.lastPathComponent
            let resourceTypes = props.compactMap(\.resourcetype)

            return WebDAVResource(
                eTag: props.compactMap(\.getetag).first,
                name: name,
                path: item.href,
                size: props.compactMap(\.getcontentlength).compactMap { Int64($0) }.first,
                contentType: props.compactMap(\.getcontenttype).first,
                lastModified: props.compactMap(\.getlastmodified).compactMap { DateFormatter.rfc2822.date(from: $0) }.first,
                isDirectory: resourceTypes.isEmpty ? nil : resourceTypes.contains { $0.collection != nil }
            )
        }
    }
}
