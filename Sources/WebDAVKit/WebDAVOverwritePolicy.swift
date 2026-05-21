//
//  WebDAVOverwritePolicy.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 17/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

public enum WebDAVOverwritePolicy: Sendable {

    /// Overwrites the resource if it already exists.
    case overwrite

    /// Fails if the resource already exists.
    case fail
}

extension WebDAVOverwritePolicy {

    var value: String {
        switch self {
        case .overwrite: "T"
        case .fail: "F"
        }
    }
}
