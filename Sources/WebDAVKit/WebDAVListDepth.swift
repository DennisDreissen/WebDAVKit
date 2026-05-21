//
//  WebDAVListDepth.swift
//  WebDAVKit
//
//  Created by Dennis Dreissen on 19/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

public enum WebDAVListDepth: Sendable {

    /// Only the resource itself
    case target

    /// The resource and its immediate children
    case targetAndChildren
}

extension WebDAVListDepth {

    var value: String {
        switch self {
        case .target: "0"
        case .targetAndChildren: "1"
        }
    }
}
