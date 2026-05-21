//
//  WebDAVResource.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 18/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

public struct WebDAVResource: Sendable, Equatable {

    /// The entity tag of the resource.
    public let eTag: String?

    /// The resource name.
    public let name: String?

    /// The absolute path of the resource.
    public let path: String

    /// The size of the resource in bytes.
    public let size: Int64?

    /// The content type of the resource.
    public let contentType: String?

    /// The date and time the resource was last modified.
    public let lastModified: Date?

    /// Whether or no the resource is a directory.
    public let isDirectory: Bool

    public init(
        eTag: String?,
        name: String?,
        path: String,
        size: Int64?,
        contentType: String?,
        lastModified: Date?,
        isDirectory: Bool
    ) {
        self.eTag = eTag
        self.name = name
        self.path = path
        self.size = size
        self.contentType = contentType
        self.lastModified = lastModified
        self.isDirectory = isDirectory
    }
}
