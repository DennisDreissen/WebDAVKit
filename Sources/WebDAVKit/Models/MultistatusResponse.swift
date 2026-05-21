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
        response.map {
            let prop = $0.propstat
                .first { $0.status.contains("200") }?
                .prop

            let name = prop?.displayname.flatMap { $0.isEmpty ? nil : $0 }
            ?? URL(string: $0.href)?.lastPathComponent

            return WebDAVResource(
                eTag: prop?.getetag,
                name: name,
                path: $0.href,
                size: prop?.getcontentlength.flatMap { Int64($0) },
                contentType: prop?.getcontenttype,
                lastModified: prop?.getlastmodified.flatMap { DateFormatter.rfc2822.date(from: $0) },
                isDirectory: prop?.resourcetype?.collection != nil
            )
        }
    }
}
