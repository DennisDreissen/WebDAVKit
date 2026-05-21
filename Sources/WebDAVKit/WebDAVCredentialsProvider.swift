//
//  WebDAVCredentialsProvider.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

public protocol WebDAVCredentialsProvider: Sendable {

    var username: String { get }
    var password: String { get }
}
